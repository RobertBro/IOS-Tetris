//
//  GameViewController.swift
//  ff
//
//  Created by RMS on 17.10.2017.
//  Copyright © 2017 RMS. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, EngineFunctions, UIGestureRecognizerDelegate{
 var scene: GameScene!
 var engine: Engine!
 var panPointReference:CGPoint?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        
        skView.isMultipleTouchEnabled = false

        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick
        
        engine = Engine()
        engine.delegate = self
        engine.startGame()
        skView.presentScene(scene)
        

    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    engine.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    engine.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        engine.dropShape()
    }
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        engine.rotateShape()
    }
    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    private func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
         engine.letShapeFall()
    }
    func nextShape() {
        let newShapes = engine.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {

            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameBegin(engine: Engine) {

        levelLabel.text="\(engine.level)"
        scoreLabel.text="\(engine.score)"
        scene.tickLengtrhMillis=TickLengthLevelOne
        if engine.nextShape != nil && engine.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: engine.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    

    @IBAction func sdfsdfdffsdf(_ sender: Any) {
        print("bullshit")
    }
        func gameEnd(engine: Engine) {
       // view.isUserInteractionEnabled = false
        scene.stopTicking()
        scene.playSound(sound: "Sounds/gameover.mp3")
        scene.collapsingLinesAnimation(linesToRemove: engine.removeAllBlocks(), fallenBlocks: engine.removeAllBlocks()){
           
            self.view.viewWithTag(2)?.isHidden=false;
            
            //engine.startGame()
        }}
    
    
    func gameNextLevel(engine: Engine) {
        levelLabel.text="\(engine.level)"
       /* zad6 if scene.tickLengtrhMillis>=100{
            scene.tickLengtrhMillis-=100
        }else if scene.tickLengtrhMillis>50{
            scene.tickLengtrhMillis-=50
            
        }*/
        scene.playSound(sound: "Sounds/levelUp.mp3")
        
    }
    
    
    func gameShapeDrop(engine: Engine) {
        scene.stopTicking()
        scene.redrawShape(shape: engine.fallingShape!) {
            engine.letShapeFall()
        }
        scene.playSound(sound: "Sounds/drop.mp3")
    }
    
    func gameShapeLand(engine: Engine) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled=false
        let removedLines=engine.removeCompletedLines()
        if removedLines.linesRemoved.count>0{
            self.scoreLabel.text="\(engine.score)"
            scene.collapsingLinesAnimation(linesToRemove: removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks){
                self.gameShapeLand(engine: engine)
            }
            scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }

    func gameShapeMove(engine: Engine) {
        scene.redrawShape(shape: engine.fallingShape!) {}
    }
    
}

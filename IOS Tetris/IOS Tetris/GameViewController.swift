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

        if engine.nextShape != nil && engine.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: engine.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameEnd(engine: Engine) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameNextLevel(engine: Engine) {
        
    }
    
    func gameShapeDrop(engine: Engine) {
        scene.stopTicking()
        scene.redrawShape(shape: engine.fallingShape!) {
            engine.letShapeFall()
        }
    }
    
    func gameShapeLand(engine: Engine) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false
        let removedLines = engine.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
                self.gameShapeLand(engine: engine)
            }
         else {
            nextShape()
        }
    }

    func gameShapeMove(engine: Engine) {
        scene.redrawShape(shape: engine.fallingShape!) {}
    }
}

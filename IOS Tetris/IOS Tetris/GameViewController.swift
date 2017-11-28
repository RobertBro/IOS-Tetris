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

class GameViewController: UIViewController, EngineFunctions {
 var scene: GameScene!
    var engine: Engine!
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
        
    }
    
    func gameShapeLand(engine: Engine) {
        scene.stopTicking()
        nextShape()
    }

    func gameShapeMove(engine: Engine) {
        scene.redrawShape(shape: engine.fallingShape!) {}
    }
}

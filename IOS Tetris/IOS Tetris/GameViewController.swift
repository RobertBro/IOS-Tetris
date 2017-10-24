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

class GameViewController: UIViewController {
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
        engine.startGame()
        // Present the scene.
        skView.presentScene(scene)
        
        scene.addPreviewShapeToScene(engine.nextShape!) {
            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick() {
        engine.fallingShape?.lowerShapeByOneRow()
        scene.redrawShape(engine.fallingShape!, completion: {})
    }
}

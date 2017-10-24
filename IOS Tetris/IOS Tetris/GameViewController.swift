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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false

        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//
//  GameViewController.swift
//  ColorSwitch
//
//  Created by Kevin Nogales on 5/24/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MenuScene(size: self.view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            // Elements of scene can be rendered in a nonfix way.
            view.ignoresSiblingOrder = true
            
            // Debug info, showing FPS and Node Count.
            // Nodes are elements contained inside of a view.
            // SK Scene is a node.
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
}

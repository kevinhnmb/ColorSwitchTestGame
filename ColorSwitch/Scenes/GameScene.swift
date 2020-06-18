//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Kevin Nogales on 5/24/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    
    override func didMove(to view: SKView) {
        self.layoutScene()
        self.setupPhysics()
    }
    
    func setupPhysics() {
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        self.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        self.colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        self.colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        self.colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        self.colorSwitch.zPosition = ZPositions.colorSwitch
        self.colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        self.colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        self.colorSwitch.physicsBody?.isDynamic = false
        self.addChild(colorSwitch)
        
        self.scoreLabel.fontName = "AvenirNext-Bold"
        self.scoreLabel.fontSize = 60.0
        self.scoreLabel.fontColor = UIColor.white
        self.scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.scoreLabel.zPosition = ZPositions.label
        self.addChild(scoreLabel)
        
        self.spawnBall()
    }
    
    func updateScoreLabel() {
        self.scoreLabel.text = "\(self.score)"
    }
    
    func spawnBall() {
        self.currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[self.currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - 25)
        // Physics Stuff
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        ball.zPosition = ZPositions.ball
        self.addChild(ball)
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: self.switchState.rawValue + 1) {
            self.switchState = newState
        } else {
            self.switchState = .red
        }
        
        self.colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore")
        
        if score > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        view?.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touching!")
        self.turnWheel()
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if self.currentColorIndex == switchState.rawValue {
                    
                    run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
                    
                    self.score += 1
                    self.updateScoreLabel()
                    
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
                    run(SKAction.playSoundFileNamed("game_over", waitForCompletion: false), completion: {
                        self.gameOver()
                    })
                }
            }
        }
    }
}

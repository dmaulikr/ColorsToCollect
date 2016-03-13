//
//  GameScene.swift
//  ColorsToCollect
//
//  Created by Greg Willis on 3/12/16.
//  Copyright (c) 2016 Willis Programming. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var touchLocation: CGPoint!
    var player: SKSpriteNode!
    var fallingBlock: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let offBlackColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    let offWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    let orangeColor = UIColor.orangeColor()
    let blueColor = UIColor(red: (18/255), green: (70/255), blue: (194/255), alpha: 1.0)
    
    var colorSelection = 0
    var colorOneSelection = 0
    var fallingBlockSpeed = 3.0
    var spawnSpeed = 1.0
    var score = 0
    var isAlive = true
    
    override func didMoveToView(view: SKView) {
        backgroundColor = offBlackColor
        physicsWorld.contactDelegate = self
        spawnPlayer()
        scoreLabel = spawnScoreLabel()
        fallingBlockTimer()
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            touchLocation = touch.locationInNode(self)
            player.position.x = touchLocation.x
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            touchLocation = touch.locationInNode(self)
            
            let colorOneArray = [blueColor, offWhiteColor, orangeColor]
            
            colorOneSelection++
            
            if colorOneSelection == 3 {
                colorOneSelection = 0
            }
            
            player.color = colorOneArray[colorOneSelection]

        }
    }
   
    override func update(currentTime: CFTimeInterval) {

    }
}

// MARK: - Spawn Functions
extension GameScene {
    
    func spawnPlayer() {
        let playerSize = CGSize(width: 50, height: 50)
        player = SKSpriteNode(color: offWhiteColor, size: playerSize)
        player.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame) * 0.2)
        player.physicsBody = SKPhysicsBody(rectangleOfSize: playerSize)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.fallingBlock
        player.physicsBody?.dynamic = false
        
        addChild(player)
    }
    
    func spawnFallingBlock() {
        let blockSize = CGSize(width: 30, height: 30)
        
        fallingBlock = SKSpriteNode(color: changeColor(), size: blockSize)
        fallingBlock.position = CGPoint(x: CGRectGetWidth(self.frame) * random(), y: CGRectGetHeight(self.frame))
        fallingBlock.physicsBody = SKPhysicsBody(rectangleOfSize: blockSize)
        fallingBlock.physicsBody?.affectedByGravity = false
        fallingBlock.physicsBody?.allowsRotation = false
        fallingBlock.physicsBody?.categoryBitMask = PhysicsCategory.fallingBlock
        fallingBlock.physicsBody?.contactTestBitMask = PhysicsCategory.player
        fallingBlock.physicsBody?.dynamic = true
        
        
        let moveDown = SKAction.moveToY(0, duration: fallingBlockSpeed)
        let destroy = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDown, destroy])
        
        fallingBlock.runAction(sequence)
        
        
        addChild(fallingBlock)
    }
    
    func spawnScoreLabel() -> SKLabelNode {
        let scoreLabel = SKLabelNode(fontNamed: "Avenir")
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetHeight(self.frame) * 0.1)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        return scoreLabel
    }
}

// MARK: - Timer Functions
extension GameScene {
    
    func fallingBlockTimer() {
        let timer = SKAction.waitForDuration(spawnSpeed)
        let spawn = SKAction.runBlock {
            if self.isAlive {
                self.spawnFallingBlock()
            }
        }
        let sequence = SKAction.sequence([timer, spawn])
        runAction(SKAction.repeatActionForever(sequence))
    }
}

// MARK: - Physics Functions
extension GameScene: SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let player: UInt32 = 1
        static let fallingBlock: UInt32 = 2
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.fallingBlock) || (firstBody.categoryBitMask == PhysicsCategory.fallingBlock && secondBody.categoryBitMask == PhysicsCategory.player)) {
            
            fallingBlockCollision(firstBody.node as! SKSpriteNode, blockTemp: secondBody.node as! SKSpriteNode)
        }
    }
    
    func fallingBlockCollision(playerTemp: SKSpriteNode, blockTemp: SKSpriteNode) {
        if playerTemp.color == blockTemp.color {
            blockTemp.removeFromParent()
            addToScore()
        } else {
            gameOver()
        }
    }
}

// MARK: - Helper functions
extension GameScene {
    
    func changeColor() -> UIColor{
        
        let colorArray = [offWhiteColor, orangeColor, blueColor]
        
        colorSelection++
        
        if colorSelection == 3 {
            colorSelection = 0
        }
        
        return colorArray[colorSelection]
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func addToScore() {
        score++
        scoreLabel.text = "Score: \(score)"
    }
    
    func gameOver() {
        scoreLabel.text = "Game Over"
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        player.removeFromParent()
        fallingBlock.removeFromParent()
        isAlive = false
        
        let wait = SKAction.waitForDuration(3.0)
        let transition = SKAction.runBlock {
            if let gameScene = GameScene(fileNamed: "GameScene"), view = self.view {
                gameScene.scaleMode = .ResizeFill
                view.presentScene(gameScene, transition: SKTransition.doorwayWithDuration(0.5))
            }
        }
        runAction(SKAction.sequence([wait, transition]))
    }
}

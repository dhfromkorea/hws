//
//  GameScene.swift
//  proj23
//
//  Created by dh on 10/18/16.
//  Copyright © 2016 dhfromkorea. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scorelabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
}

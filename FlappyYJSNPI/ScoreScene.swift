//
//  ScoreScene.swift
//  FlappyYJSNPI
//
//  Created by Moe_MCU~ on 29/6/2020.
//

import SpriteKit
import GameplayKit

//var audioNode3 = SKAudioNode(fileNamed: "effect3.mp3")
class ScoreScene: SKScene {
    //var bird: SKSpriteNode!
    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    lazy var gameOverLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        //zPosition = 300
        label.text = "Game Over"
        return label

    }()
    override func didMove(to view: SKView){
        //audioNode3.autoplayLooped = false
        //self.addChild(audioNode3)
        self.backgroundColor = SKColor(red: 110.0/255.0, green: 190.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        floor1 = SKSpriteNode(imageNamed: "floor")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = CGPoint(x: 0, y: 0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "floor")
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        addChild(floor2)
        
        addChild(scoreLabel)
        addChild(BSLabel)
        //audioNode3.run(SKAction.play())
        
        gameOverLabel.zPosition = 300
        //设置gameOverLabel其实位置在屏幕顶部
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        addChild(gameOverLabel)
    }
    
    lazy var scoreLabel: SKLabelNode = {
        let scorelabel = SKLabelNode(fontNamed: "Baby-blocks")
        scorelabel.fontSize = 46
        scorelabel.verticalAlignmentMode = .top
        scorelabel.horizontalAlignmentMode = .center
        scorelabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        
        if((UserDefaults.standard.integer(forKey: "Meters") % 10) == 0 ){
            scorelabel.text = "score\((Double(UserDefaults.standard.integer(forKey: "Meters"))) / 100.0)0"
        }
        else{
            scorelabel.text = "score\((Double(UserDefaults.standard.integer(forKey: "Meters"))) / 100.0)"
        }
        
        return scorelabel
    }()
    
    lazy var BSLabel: SKLabelNode = {
        let BSlabel = SKLabelNode(fontNamed: "Baby-blocks")
        BSlabel.fontSize = 32
        BSlabel.verticalAlignmentMode = .top
        BSlabel.horizontalAlignmentMode = .center
        BSlabel.zPosition = 400
        BSlabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        if((UserDefaults.standard.integer(forKey: "BS") % 10) == 0 ){
            BSlabel.text = "best score\((Double(UserDefaults.standard.integer(forKey: "BS"))) / 100.0)0"
        }
        else{
            BSlabel.text = "best score\((Double(UserDefaults.standard.integer(forKey: "BS"))) / 100.0)"
        }
        return BSlabel
    }()
    
    func moveScene() {
        //make floor move
        floor1.position = CGPoint(x: floor1.position.x - 1, y: floor1.position.y)
        floor2.position = CGPoint(x: floor2.position.x - 1, y: floor2.position.y)
        //check floor position
        if floor1.position.x < -floor1.size.width {
            floor1.position = CGPoint(x: floor2.position.x + floor2.size.width, y: floor1.position.y)
        }
        if floor2.position.x < -floor2.size.width {
            floor2.position = CGPoint(x: floor1.position.x + floor1.size.width, y: floor2.position.y)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        print("back")
        let Gamescene_main = GameScene(size: self.size)
        Gamescene_main.scaleMode = .aspectFill
        self.view?.presentScene(Gamescene_main)
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveScene()
    }
}


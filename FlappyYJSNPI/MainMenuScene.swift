//
//  MainMenuScene.swift
//  FloppyYJSNPI
//
//  Created by Moe_MCU~ on 29/6/2020.
//

import SpriteKit
import GameplayKit

//var audioNode1 = SKAudioNode(fileNamed: "effect1.mp3")
class MainMenuScene: SKScene, SKPhysicsContactDelegate {
    var bird: SKSpriteNode!
    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    
    override func didMove(to view: SKView){
        
        self.backgroundColor = SKColor(red: 110.0/255.0, green: 190.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        //audioNode1.autoplayLooped = false
        //self.addChild(audioNode1)
        floor1 = SKSpriteNode(imageNamed: "floor")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = CGPoint(x: 0, y: 0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "floor")
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        addChild(floor2)
        
        addChild(titleLabel)
        addChild(pressLabel)
        addChild(BSLabel)
        bird = SKSpriteNode(imageNamed: "yjsnpi1")
        bird.position = CGPoint(x: self.size.width * 0.3, y: self.size.height * 0.5)
        let flyAction = SKAction.animate(with: [SKTexture(imageNamed: "yjsnpi1"),
                                                SKTexture(imageNamed: "yjsnpi2"),
                                                SKTexture(imageNamed: "yjsnpi1"),
                                                SKTexture(imageNamed: "yjsnpi2")],
                                         timePerFrame: 0.15)
        let repeatBird = SKAction.repeatForever(flyAction)
        let upMove = SKAction.move(to: CGPoint(x: self.size.width * 0.3, y: self.size.height * 0.55), duration: 1.0)
        let downMove = SKAction.move(to: CGPoint(x: self.size.width * 0.3, y: self.size.height * 0.45), duration: 1.0)
        let moveList = SKAction.sequence([upMove,downMove])
        let foreverMove = SKAction.repeatForever(moveList)
        let birdGroup = SKAction.group([repeatBird, foreverMove])
        bird.run(SKAction.repeatForever(birdGroup))
        addChild(bird)
    }
    
    lazy var titleLabel: SKLabelNode = {
        let titlelabel = SKLabelNode(fontNamed: "Chalkduster")
        titlelabel.fontSize = 46
        titlelabel.verticalAlignmentMode = .top
        titlelabel.horizontalAlignmentMode = .center
        titlelabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.8)
        titlelabel.text = "FlappyYJSNPI"
        return titlelabel
    }()
    
    lazy var pressLabel: SKLabelNode = {
        let presslabel = SKLabelNode(fontNamed: "Baby-blocks")
        presslabel.fontSize = 46
        presslabel.verticalAlignmentMode = .top
        presslabel.horizontalAlignmentMode = .center
        presslabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        presslabel.text = "press to start!"
        return presslabel
    }()
    
    lazy var BSLabel: SKLabelNode = {
        let BSlabel = SKLabelNode(fontNamed: "Baby-blocks")
        BSlabel.fontSize = 32
        BSlabel.verticalAlignmentMode = .top
        BSlabel.horizontalAlignmentMode = .center
        BSlabel.zPosition = 400
        BSlabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.1)
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
        
        print("start")
        //audioNode1.run(SKAction.play())
        SKTAudio.sharedInstance().playSoundEffect("effect1.mp3")
        
        let Gamescene_main = GameScene(size: self.size)
        Gamescene_main.scaleMode = .aspectFill
        self.view?.presentScene(Gamescene_main)
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveScene()
    }
}

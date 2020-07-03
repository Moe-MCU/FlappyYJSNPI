//
//  GameScene.swift
//  FloppyYJSNPI
//
//  Created by Moe_MCU~ on 27/6/2020.
//

import SpriteKit
import GameplayKit

let birdCategory: UInt32 = 0x1 << 0
let pipeCategory: UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2

var audioNode2 = SKAudioNode(fileNamed: "effect2.mp3")

//⚠️SKPhysicsContactDelegate⬇️
class GameScene: SKScene, SKPhysicsContactDelegate {
    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    var bird: SKSpriteNode!
    var gameStatus: GameStatus = .idle
    lazy var metersLabel: SKLabelNode = {
        //let label = SKLabelNode(text: "score:0")
        let label = SKLabelNode(fontNamed: "Baby-blocks")
        //label.zPosition = 300
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        return label
    }()
    var meters = 0 {
        didSet{
            if((meters % 10) == 0 ){
                metersLabel.text = "score\((Double(meters)) / 100.0)0"
            }
            else{
                metersLabel.text = "score\((Double(meters)) / 100.0)"
            }
        }
    }
    lazy var tapLabel: SKLabelNode = {
        let taplabel = SKLabelNode(fontNamed: "Chalkduster")
        taplabel.fontSize = 46
        taplabel.verticalAlignmentMode = .top
        taplabel.horizontalAlignmentMode = .center
        taplabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        taplabel.text = "tap ↑"
        return taplabel
    }()
    override func didMove(to view: SKView){
        self.backgroundColor = SKColor(red: 110.0/255.0, green: 190.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        //phy_set
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        audioNode2.autoplayLooped = false
        self.addChild(audioNode2)
        
        floor1 = SKSpriteNode(imageNamed: "floor")
        floor1.anchorPoint = CGPoint(x: 0, y: 0)
        floor1.position = CGPoint(x: 0, y: 0)
        addChild(floor1)
        
        floor2 = SKSpriteNode(imageNamed: "floor")
        floor2.anchorPoint = CGPoint(x: 0, y: 0)
        floor2.position = CGPoint(x: floor1.size.width, y: 0)
        addChild(floor2)
        
        addChild(tapLabel)
        
        //配置地面1的物理体
        floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
        floor1.physicsBody?.categoryBitMask = floorCategory
        floor1.zPosition = 200
        //配置地面2的物理体
        floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
        floor2.physicsBody?.categoryBitMask = floorCategory
        floor2.zPosition = 200
        
        // Meter Dashboard
        //metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 1.0)
        metersLabel.zPosition = 200
        //metersLabel.run(SKAction.move(by: CGVector(dx:self.size.width * 0.5, dy:self.size.height), duration: 0.0))
        
        bird = SKSpriteNode(imageNamed: "yjsnpi1")
        addChild(bird)
        
        bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
        bird.physicsBody?.allowsRotation = false  //禁止旋转
        bird.physicsBody?.categoryBitMask = birdCategory //设置小鸟物理体标示
        bird.physicsBody?.contactTestBitMask = floorCategory | pipeCategory  //设置可以小鸟碰撞检测的物理体
        
        addChild(metersLabel)
        metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.95)
        //metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 1.0)
        shuffle()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameStatus {
        case .idle:
            metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.95)
            tapLabel.removeFromParent()
            startGame() //如果在初始化状态下，玩家点击屏幕则开始游戏
        case .running:
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            //SKTAudio.sharedInstance().playSoundEffect("effect2.mp3")
            audioNode2.run(SKAction.stop())
            audioNode2.run(SKAction.play())
            print("🐦⬆️")
        case .over:
            metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.95)
            shuffle() //如果在游戏结束状态下，玩家点击屏幕则进入初始化状态
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        //先检查游戏状态是否在运行中，如果不在运行中则不做操作，直接return
        if gameStatus != .running { return }
        //为了方便我们判断碰撞的bodyA和bodyB的categoryBitMask哪个小，小的则将它保存到新建的变量bodyA里的，大的则保存到新建变量bodyB里
        var bodyA : SKPhysicsBody
        var bodyB : SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        }else {
            bodyA = contact.bodyB
            bodyB = contact.bodyA
        }
        //接下来判断bodyA是否为小鸟，bodyB是否为水管或者地面，如果是则游戏结束，直接调用gameOver()方法
        if (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory) || (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory) {
            gameOver()
        }
    }

    func addPipes(topSize: CGSize, bottomSize: CGSize) {
        //创建上水管
        let topTexture = SKTexture(imageNamed: "pipe") //利用上水管图片创建一个上水管纹理对象
        let topPipe = SKSpriteNode(texture: topTexture, size: topSize) //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        topPipe.name = "pipe" //给这个水管取个名字叫pipe
        topPipe.position = CGPoint(x: self.size.width + topPipe.size.width * 0.5, y: self.size.height - topPipe.size.height * 0.5) //设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        //创建下水管，每一句方法都与上面创建上水管的相同意义
        let bottomTexture = SKTexture(imageNamed: "pipe")
        let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
        bottomPipe.name = "pipe"
        bottomPipe.position = CGPoint(x: self.size.width + bottomPipe.size.width * 0.5, y:  bottomPipe.size.height * 0.5) //设置下水管的垂直位置为底部贴着地面的顶部，水平位置在屏幕右侧之外
        //phy
        topPipe.physicsBody = SKPhysicsBody(texture: topTexture, size: topSize)
        topPipe.physicsBody?.isDynamic = false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        bottomPipe.physicsBody = SKPhysicsBody(texture: bottomTexture, size: bottomSize)
        bottomPipe.physicsBody?.isDynamic = false
        bottomPipe.physicsBody?.categoryBitMask = pipeCategory
        //将上下水管添加到场景里
        addChild(topPipe)
        addChild(bottomPipe)
    }

    func createRandomPipes() {
        //先计算地板顶部到屏幕顶部的总可用高度
        //let height = self.size.height// - self.floor1.size.height
        //计算上下管道中间的空档的随机高度，最小为空档高度为2.5倍的小鸟的高度，最大高度为3.5倍的小鸟高度
        let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height))) + bird.size.height * 1.5
        //管道宽度在60
        let pipeWidth = CGFloat(60.0)
        //随机计算顶部pipe的随机高度，这个高度肯定要小于(总的可用高度减去空档的高度)
        let topPipeHeight = CGFloat(arc4random_uniform(UInt32(self.size.height - pipeGap * 1.8)))
        //总可用高度减去空档gap高度减去顶部水管topPipe高度剩下就为底部的bottomPipe高度
        let bottomPipeHeight = self.size.height - pipeGap - topPipeHeight
        //调用添加水管到场景方法
        addPipes(topSize: CGSize(width: pipeWidth, height: topPipeHeight), bottomSize: CGSize(width: pipeWidth, height: bottomPipeHeight))

    }
    lazy var gameOverLabel: SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        //zPosition = 300
        label.text = "Game Over"
        return label

    }()
    
    func startCreateRandomPipesAction() {
        //创建一个等待的action,等待时间的平均值为3.5秒，变化范围为1秒
        let waitAct = SKAction.wait(forDuration: 3.5, withRange: 1.0)
        //创建一个产生随机水管的action，这个action实际上就是调用一下我们上面新添加的那个createRandomPipes()方法
        let generatePipeAct = SKAction.run {
            self.createRandomPipes()
        }
        //让场景开始重复循环执行"等待" -> "创建" -> "等待" -> "创建"。。。。。
        //并且给这个循环的动作设置了一个叫做"createPipe"的key来标识它
        run(SKAction.repeatForever(SKAction.sequence([waitAct, generatePipeAct])), withKey: "createPipe")
    }
    
    func stopCreateRandomPipesAction() {
        self.removeAction(forKey: "createPipe")
    }
    
    func removeAllPipesNode() {
        for pipe in self.children where pipe.name == "pipe" { //循环检查场景的子节点，同时这个子节点的名字要为pipe
            pipe.removeFromParent() //将水管这个节点从场景里移除掉
        }
    }

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
    
    func birdStartFly() {
        let flyAction = SKAction.animate(with: [SKTexture(imageNamed: "yjsnpi1"),
                                                SKTexture(imageNamed: "yjsnpi2"),
                                                SKTexture(imageNamed: "yjsnpi1"),
                                                SKTexture(imageNamed: "yjsnpi2")],
                                         timePerFrame: 0.15)
        bird.run(SKAction.repeatForever(flyAction), withKey: "fly")
    }
    func birdStopFly() {
        bird.removeAction(forKey: "fly")
    }
    
    enum GameStatus {
        case idle //初始化
        case running //游戏运行中
        case over //游戏结束
    }
    func shuffle()  {
        gameStatus = .idle
        meters = 0
        //metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 1.0)
        //metersLabel.run(SKAction.move(by: CGVector(dx:self.size.width * 0.5, dy:self.size.height * 1.0), duration: 0.3))
        bird.position = CGPoint(x: self.size.width * 0.3, y: self.size.height * 0.5)
        bird.physicsBody?.isDynamic = false
        birdStartFly()
        removeAllPipesNode()
        gameOverLabel.removeFromParent()
    }
    func startGame()  {
        //metersLabel.run(SKAction.move(by: CGVector(dx:self.size.width * 0.5, dy:self.size.height * 0.95), duration: 0.3))
        gameStatus = .running
        bird.physicsBody?.isDynamic = true
        startCreateRandomPipesAction()
    }
    func gameOver()  {
        gameStatus = .over
        birdStopFly()
        stopCreateRandomPipesAction()
        //禁止用户点击屏幕
        isUserInteractionEnabled = false
        
        metersLabel.run(SKAction.move(by: CGVector(dx:self.size.width * 0.5, dy:self.size.height), duration: 0.3))
        //添加gameOverLabel到场景里
        UserDefaults.standard.set(meters, forKey: "Meters")
        if(meters >= UserDefaults.standard.integer(forKey: "BS")){
            UserDefaults.standard.set(meters, forKey: "BS")
        }
        SKTAudio.sharedInstance().playBackgroundMusic("effect3.mp3")
        addChild(gameOverLabel)
        gameOverLabel.zPosition = 300
        //设置gameOverLabel其实位置在屏幕顶部
        gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
        //让gameOverLabel通过一个动画action移动到屏幕中间
        gameOverLabel.run(SKAction.move(by: CGVector(dx:0, dy:-self.size.height * 0.5), duration: 1.5), completion: {
            self.isUserInteractionEnabled = true
            let Scorescene_main = ScoreScene(size: self.size)
            Scorescene_main.scaleMode = .aspectFill
            self.view?.presentScene(Scorescene_main)
        })
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameStatus == .running {
            meters += 1
        }
        if gameStatus != .over {
            moveScene()
            for pipeNode in self.children where pipeNode.name == "pipe" {
                //因为要用到水管的size，但是SKNode没有size属性，所以我们要把它转成SKSpriteNode
                if let pipeSprite = pipeNode as? SKSpriteNode {
                    //将水管左移1
                    pipeSprite.position = CGPoint(x: pipeSprite.position.x - 1, y: pipeSprite.position.y)
                    //检查水管是否完全超出屏幕左侧了，如果是则将它从场景里移除掉
                    if pipeSprite.position.x < -pipeSprite.size.width * 0.5 {
                        pipeSprite.removeFromParent()
                    }
                }
            }
        }
    }
}

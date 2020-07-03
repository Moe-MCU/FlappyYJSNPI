//
//  GameViewController.swift
//  FloppyYJSNPI
//
//  Created by Moe_MCU~ on 27/6/2020.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            let Mainscene = MainMenuScene(size: view.bounds.size) //通过代码创建一个Mainscene类的实例对象
            Mainscene.scaleMode = .aspectFill
            view.presentScene(Mainscene)
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

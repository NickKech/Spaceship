//
//  GameScene.swift
//  Spaceship
//
//  Created by Nikolaos Kechagias on 20/08/15.
//  Copyright (c) 2015 Nikolaos Kechagias. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    /* 1 */
    // Preloads the sound effects
    let soundMessage = SKAction.playSoundFileNamed("Message.m4a", waitForCompletion: false)
    let soundBullet = SKAction.playSoundFileNamed("Bullet.m4a", waitForCompletion: false)
    let soundExplosion = SKAction.playSoundFileNamed("Explosion.m4a", waitForCompletion: false)
    let soundBigExplosion = SKAction.playSoundFileNamed("BigExplosion.m4a", waitForCompletion: false)
    let soundSmallExplosion = SKAction.playSoundFileNamed("SmallExplosion.m4a", waitForCompletion: false)
    
    /* 3 */
    var spaceship: SKSpriteNode!  // Image of spaceship
    
    /* 4 */
    // This property stores spaceship's speed
    let spaceshipHorizontalSpeed: CGFloat = 10.0
    
    /* 5 */
    // This property indicates the movement's direction of the spaceship (Left, Right or Stopped)
    var spaceshipHorizontalMovement = SpaceshipMovement.stopped
    
    /* 1 */
    // Sprite of the shield's energy (Progress Bar)
    var shieldProgressbar: ProgressBarNode!
    
    // Helpful variables for the background scrolling
    var delta = 0.0
    var lastUpdate = 0.0
    
    let backgroundLayer = SKNode() 	// Initializes background Layer
    let backgroundSpeed = 50.0      // Speed of the background layer
    
    /* 1 */
    var scoreLabel = LabelNode(fontNamed: "Gill Sans Bold Italic")
    
    /* 3 */
    // This property stores the score
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    /* 1 */
    var energyLabel = LabelNode(fontNamed: "Gill Sans Bold Italic")
    /* 2 */
    
    
    // This property indicates (determines) the game states (Ready, Playing or GameOver)
    var gameState: GameState = .ready
    
    
    
    
    override func didMove(to view: SKView) {
        /* 1 */
        addBackground()
        
        /* 2 */
        initPhysicsWorld()
        
        /* Add HUD */
        initHUD()
        
        /* Show Start Game Message */
        showMessage("StartGame")
    }
    
    // MARK: - Game States
    
    func startGame() {
        /* 1 */
        addSpaceship()
        
        /* 2 */
        initEnemies()
        
        /* Reset Score */
        score = 0
        
        /* Refills Shield's Energy */
        shieldProgressbar.full()
    }
    
    
    // MARK: - Game Logic
    
    func addSpaceship() {
        /* 1 */
        spaceship = SKSpriteNode(imageNamed: "Plane")
        spaceship.name = "Plane"
        spaceship.zPosition = zOrderValue.spaceship.rawValue
        spaceship.position = CGPoint(x: size.width * 0.50, y: spaceship.size.height * 1.5)
        addChild(spaceship)
        
        /* 2 */
        spaceship.physicsBody = SKPhysicsBody(circleOfRadius: spaceship.size.height * 0.50)
        spaceship.physicsBody?.allowsRotation = false
        spaceship.physicsBody?.usesPreciseCollisionDetection = true
        /* 3 Sets the category of the spaceship's physics-body.*/
        spaceship.physicsBody?.categoryBitMask = ColliderCategory.spaceship.rawValue
        /* 4 The spaceship must collides with enemy’s spaceships and bullets.*/
        spaceship.physicsBody?.collisionBitMask = ColliderCategory.enemyBullet.rawValue | ColliderCategory.enemy.rawValue
        /* 5 When the spaceship collides with enemy’s spaceships and bullets, the "Contact Delegate" must be called.*/
        spaceship.physicsBody?.contactTestBitMask = ColliderCategory.enemyBullet.rawValue | ColliderCategory.enemy.rawValue
        
        /* 3 */
        let smokeTrail = SKEmitterNode(fileNamed: "SmokeTrail")
        smokeTrail!.position = CGPoint(x: 0, y: -spaceship.size.height / 2)
        spaceship.addChild(smokeTrail!)
        
        /* Auto-fire */
        autoFire()
    }
    
    func autoFire() {
        /* 1 */
        let spawn = SKAction.run() {
            self.addSpaceshipBullet()
        }
        
        /* 2 */
        let delay = SKAction.wait(forDuration: 1.0)
        
        /* 3 */
        let sequence = SKAction.sequence([spawn, delay])
        
        /* 4 */
        let forever = SKAction.repeatForever(sequence)
        
        /* 5 */
        run(forever, withKey: "autofire")
    }
    
    func addSpaceshipBullet() {
        /* 1 */
        let bullet = SKSpriteNode(imageNamed: "PlaneBullet")
        bullet.name = "PlaneBullet"
        bullet.zPosition = zOrderValue.spaceship.rawValue
        bullet.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + spaceship.size.height / 2)
        addChild(bullet)
        
        /* 2 */
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.allowsRotation = false
        
        /* 3 */
        bullet.physicsBody?.categoryBitMask = ColliderCategory.spaceshipBullet.rawValue
        bullet.physicsBody?.collisionBitMask = ColliderCategory.enemy.rawValue
        bullet.physicsBody?.contactTestBitMask = ColliderCategory.enemy.rawValue
        /* 4 */
        let target = CGPoint(x: bullet.position.x, y: size.height * 1.25)
        let move = SKAction.move(to: target, duration: 2.0)
        
        /* 5 */
        let remove = SKAction.removeFromParent()
        
        /* 6 */
        let sequence = SKAction.sequence([soundBullet, move, remove])
        
        /* 7 */
        bullet.run(sequence)
    }
    
    
    func initEnemies() {
        /*1 */
        let spawn = SKAction.run() {
            self.addEnemy()
        }
        
        /* 2 */
        let delay = SKAction.wait(forDuration: 1.5)
        
        /* 3 */
        let sequence = SKAction.sequence([spawn, delay])
        
        /* 4 */
        let forever = SKAction.repeatForever(sequence)
        
        /* 5 */
        run(forever, withKey: "SpawnEnemies")
    }
    
    func addEnemy(){
        /* 1 */
        let start = CGPoint(x: randomBetween(0, max: UInt32(size.width)), y: size.height * 1.25)
        let end = CGPoint(x: randomBetween(0, max: UInt32(size.width)), y: -100)
        
        /* 2 */
        let enemy = SKSpriteNode(imageNamed: "Enemy")
        enemy.name = "Enemy"
        enemy.zPosition = zOrderValue.spaceship.rawValue
        enemy.position = start
        addChild(enemy)
        
        /* 3 */
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: spaceship.size.height * 0.40)
        enemy.physicsBody?.allowsRotation = false
        
        /* 4 */
        enemy.physicsBody?.categoryBitMask = ColliderCategory.enemy.rawValue
        enemy.physicsBody?.collisionBitMask = ColliderCategory.spaceshipBullet.rawValue | ColliderCategory.spaceship.rawValue
        //enemy.physicsBody?.contactTestBitMask = ColliderCategory.SpaceshipBullet.rawValue | ColliderCategory.Spaceship.rawValue
        
        /* 5 */
        let smoke = SKEmitterNode(fileNamed: "EnemySmokeTrail")
        smoke!.position = CGPoint(x: 0, y: enemy.size.height / 2)
        enemy.addChild(smoke!)
        
        /* 6 */
        let move = SKAction.move(to: end, duration: 5.0)
        
        /* 7 */
        let remove = SKAction.removeFromParent()
        
        /* 8 */
        let sequence = SKAction.sequence([move, remove])
        
        /* 9 */
        enemy.run(sequence)
        
        /* Fires Enemy */
        
        enemyAutofire(enemy)
        
    }
    
    func enemyAutofire(_ enemy: SKSpriteNode) {
        /* 1 */
        let secs = TimeInterval(randomBetween(1, max: 3))
        let wait = SKAction.wait(forDuration: secs)
        
        /* 2 */
        let fire = SKAction.run() {
            self.addEnemyBullet(enemy)
        }
        
        /* 3 */
        run(SKAction.sequence([wait, fire]))
    }
    
    func addEnemyBullet(_ enemy: SKSpriteNode) {
        let bullet = SKSpriteNode(imageNamed: "EnemyBullet")
        bullet.name = "EnemyBullet"
        bullet.zPosition = zOrderValue.spaceship.rawValue
        bullet.position = CGPoint(x: enemy.position.x, y: enemy.position.y - enemy.size.height / 2)
        addChild(bullet)
        
        /* 2 */
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.allowsRotation = false
        
        /* 3 */
        bullet.physicsBody?.categoryBitMask = ColliderCategory.enemyBullet.rawValue
        bullet.physicsBody?.collisionBitMask = ColliderCategory.spaceship.rawValue
        //bullet.physicsBody?.contactTestBitMask = ColliderCategory.Spaceship.rawValue
        
        /* 4 */
        let target = CGPoint(x: bullet.position.x, y: -125)
        let move = SKAction.move(to: target, duration: 2.0)
        
        /* 5 */
        let remove = SKAction.removeFromParent()
        
        /* 6 */
        let sequence = SKAction.sequence([move, remove])
        
        /* 7 */
        bullet.run(sequence)
    }
    
    
    
    
    
    // MARK: - Library
    func randomBetween(_ min: UInt32, max: UInt32) -> CGFloat {
        return CGFloat(arc4random_uniform(max + 1 - min) + min)
    }
    
    func showMessage(_ imagedNamed: String) {
        /* 1 */
        let panel = SKSpriteNode(imageNamed: imagedNamed)
        panel.zPosition = zOrderValue.message.rawValue
        panel.position = CGPoint(x: size.width * 0.5, y: -size.height)
        panel.name = imagedNamed
        addChild(panel)
        
        /* 2 */
        let move = SKAction.move(to: CGPoint(x: size.width * 0.5, y: size.height / 2), duration: 0.5)
        panel.run(SKAction.sequence([soundMessage, move]))
    }
    
    
    
    
    
    // MARK: - User Interface
    
    func initHUD() {
        /* 1 */
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.shadowColor = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.50)
        scoreLabel.zPosition = zOrderValue.hud.rawValue
        scoreLabel.position = CGPoint(x: size.width * 0.25, y: size.height - 32)
        addChild(scoreLabel)
        
        /* 2 */
        energyLabel.text = "Energy: "
        energyLabel.fontSize = 32
        energyLabel.fontColor = SKColor.yellow
        energyLabel.shadowColor = SKColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.50)
        energyLabel.zPosition = zOrderValue.hud.rawValue
        energyLabel.position = CGPoint(x: size.width * 0.60, y: size.height - 32)
        addChild(energyLabel)
        
        /* 3 */
        shieldProgressbar = ProgressBarNode()
        shieldProgressbar.zPosition = zOrderValue.hud.rawValue
        shieldProgressbar.position = CGPoint(x: size.width * 0.7, y: size.height - 24)
        addChild(shieldProgressbar)
    }
    
    
    
    
    // MARK: - Physics
    
    func initPhysicsWorld() {
        /* 1 */
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /* 2 */
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState != .playing {
            return
        }
        
        
        
        if let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node {
            /* 1 */
            let catA = contact.bodyA.categoryBitMask;
            let catB = contact.bodyB.categoryBitMask;
            
            if catA == ColliderCategory.enemy.rawValue && catB == ColliderCategory.spaceshipBullet.rawValue {
                /* 2 */
                bulletCollidesWithEnemy(nodeB, enemy: nodeA)
            } else  if catB == ColliderCategory.enemy.rawValue && catA == ColliderCategory.spaceshipBullet.rawValue {
                /* 2 */
                bulletCollidesWithEnemy(nodeA, enemy: nodeB)
            } else if catA == ColliderCategory.spaceship.rawValue && catB == ColliderCategory.enemy.rawValue {
                /* 3 */
                spaceshipCollidesWithEnemy(nodeB)
            } else if catB == ColliderCategory.spaceship.rawValue && catA == ColliderCategory.enemy.rawValue {
                /* 3 */
                spaceshipCollidesWithEnemy(nodeA)
            } else if catA == ColliderCategory.spaceship.rawValue && catB == ColliderCategory.enemyBullet.rawValue {
                /* 4 */
                bulletCollidesWithSpaceship(nodeB)
            } else if catB == ColliderCategory.spaceship.rawValue && catA == ColliderCategory.enemyBullet.rawValue {
                /* 4 */
                bulletCollidesWithSpaceship(nodeA)
            }
        }
        
        
    }
    
    func updateScore() {
        score += 1
    }
    
    func explosionAt(_ location: CGPoint, scale: CGFloat) {
        /* 1 */
        var textures = [SKTexture]()
        for index in 1 ... 5 {
            let texture =  SKTexture(imageNamed: "Explosion-\(index)")
            textures.append(texture)
        }
        
        /* 2 */
        let explosion = SKSpriteNode(texture: SKTexture(imageNamed: "Explosion-1"))
        explosion.position = location
        explosion.zPosition = zOrderValue.explosion.rawValue
        explosion.setScale(scale)
        addChild(explosion)
        
        /* 3 */
        let animation = SKAction.animate(with: textures, timePerFrame: 0.10)
        /* 4 */
        let remove = SKAction.removeFromParent()
        /* 5 */
        let sequence = SKAction.sequence([animation, remove])
        /* 6 */
        explosion.run(sequence)
    }
    
    
    func bulletCollidesWithEnemy(_ bullet: SKNode, enemy: SKNode) {
        /* 1 */
        explosionAt(enemy.position, scale: 0.75)
        
        /* 2 */
        run(soundExplosion)
        
        /* 3 */
        bullet.removeFromParent()
        enemy.removeFromParent()
        
        /* update score */
        updateScore()
    }
    
    
    func spaceshipCollidesWithEnemy(_ enemy: SKNode) {
        /* 1 */
        explosionAt(enemy.position, scale: 0.75)
        
        /* 2 */
        run(soundExplosion)
        
        /* 3 */
        enemy.removeFromParent()
        
        /* 4 */
        removeAction(forKey: "autofire")
        
        /* 5*/
        explosionAt(spaceship.position, scale: 1.0)
        
        /* 6 */
        spaceship.removeFromParent()
        
        /* 7 */
        run(soundBigExplosion)
        
        /* Reset shield's energy */
        shieldProgressbar.empty()
        
        /* Game Over */
        gameOver()
    }
    
    
    
    func spaceshipCollidesEnemy(_ ship: SKNode, enemy: SKNode) {
        /* 1 */
        explosionAt(enemy.position, scale: 0.75)
        
        /* 2 */
        run(soundExplosion)
        
        /* 3 */
        removeAction(forKey: "autofire")
        
        /* 4 */
        ship.removeFromParent()
        enemy.removeFromParent()
        
        /* Reset shield's energy */
        shieldProgressbar.empty()
        
        /* 5*/
        explosionAt(ship.position, scale: 1.0)
        
        /* 6 */
        run(soundBigExplosion)
        
        /* Game Over */
        gameOver()
    }
    
    func gameOver() {
        /* 1 */
        gameState = .gameOver
        
        /* 2 */
        removeAllActions()
        
        /* 3 */
        enumerateChildNodes(withName: "Enemy"){ (child, index) in
            child.removeAllActions()
            child.removeFromParent()
        }
        
        enumerateChildNodes(withName: "EnemyBullet"){ (child, index) in
            child.removeAllActions()
            child.removeFromParent()
        }
        
        /* 4 */
        showMessage("GameOver")
    }
    
    
    func bulletCollidesSpaceship(_ bullet: SKNode, ship: SKNode) {
        /* 1 */
        explosionAt(bullet.position, scale: 0.25)
        
        /* 2 */
        run(soundSmallExplosion)
        
        /* 3 */
        bullet.removeFromParent()
        
        /* Decrease shield's energy and check the energy*/
        if shieldProgressbar.decrease() <= 0 {
            /* 6 */
            explosionAt(ship.position, scale: 1.0)
            
            /* 7 */
            run(soundBigExplosion)
            
            /* Game Over */
            gameOver()
        }
    }
    
    
    
    func bulletCollidesWithSpaceship(_ bullet: SKNode) {
        /* 1 */
        explosionAt(bullet.position, scale: 0.25)
        
        /* 2 */
        run(soundSmallExplosion)
        
        /* 3 */
        bullet.removeFromParent()
        
        /* Decrease shield's energy and check the energy*/
        if shieldProgressbar.decrease() <= 0 {
            /* 6 */
            explosionAt(spaceship.position, scale: 1.0)
            
            /* 7 */
            run(soundBigExplosion)
            
            /* Game Over */
            gameOver()
        }
    }
    
    
    // MARK: - Background
    
    func addBackground() {
        /* 1 */
        addChild(backgroundLayer)
        /* 2 */
        for index in 0 ..< 2 {
            /* 3 */
            let background = SKSpriteNode(imageNamed: "Background")
            background.name = "Background"
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: 0, y: CGFloat(index) * size.height)
            background.zPosition = zOrderValue.background.rawValue
            backgroundLayer.addChild(background)
        }
    }
    
    func scrollBackground() {
        /* 1 */
        let yStep = -backgroundSpeed * delta
        backgroundLayer.position = CGPoint(x: 0, y: backgroundLayer.position.y + CGFloat(yStep))
        
        /* 2 */
        backgroundLayer.enumerateChildNodes(withName: "Background"){ (child, index) in
            /* 3 */
            let backgroundPosition = self.backgroundLayer.convert(child.position, to: self)
            /* 4 */
            if backgroundPosition.y <= -child.frame.size.height {
                child.position = CGPoint(x: child.position.x, y: child.position.y + child.frame.size.height * 2)
            }
        }
    }
    
    
    func moveSpaceshipBy(_ distance: CGFloat) {
        /* 1 */
        let maxX = size.width - spaceship.size.width / 2
        let minX = spaceship.size.width / 2
        
        /* 2 */
        let newX = max(min(maxX, spaceship.position.x + distance),minX)
        
        /* 3 */
        spaceship.position = CGPoint(x: newX, y: spaceship.position.y)
    }
    
    
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if gameState == .playing {
            
            /* 1 */
            if lastUpdate == 0.0 {
                delta = 0
            }else{
                delta = currentTime - lastUpdate
            }
            lastUpdate = currentTime
            
            /* 2 */
            scrollBackground()
            
            if spaceshipHorizontalMovement == SpaceshipMovement.left {
                moveSpaceshipBy(-spaceshipHorizontalSpeed)
            } else if spaceshipHorizontalMovement == SpaceshipMovement.right {
                moveSpaceshipBy(spaceshipHorizontalSpeed)
            }
        }
    }
    
    
    func startNewGame() {
        /* 1 */
        let scene = GameScene(size: self.size)
        
        /* 2 */
        self.scene?.view?.presentScene(scene)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first?.location(in: self)
        /* 1 */
        if gameState == .ready {
            if let startGameMessage = childNode(withName: "StartGame") {
                gameState = .playing
                startGameMessage.removeFromParent()
                startGame()
            }
        }
        
        /* 2 */
        if gameState == .gameOver {
            startNewGame()
        }
        
        /* 3 */
        if gameState == .playing {
            if location!.x >= size.width / 2 {
                /* 4 */
                spaceshipHorizontalMovement = SpaceshipMovement.right
            } else {
                /* 5 */
                spaceshipHorizontalMovement = SpaceshipMovement.left
            }
        }

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spaceshipHorizontalMovement = SpaceshipMovement.stopped
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
       
    }
    
    
}

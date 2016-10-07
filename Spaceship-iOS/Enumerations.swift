//
//  Enumerations.swift
//  Spaceship
//
//  Created by Nikolaos Kechagias on 20/08/15.
//  Copyright © 2015 Nikolaos Kechagias. All rights reserved.
//

import SpriteKit

// The drawing order of objects in z-axis (zPosition property)
enum zOrderValue: CGFloat {
    case background, spaceship, explosion, hud, message
}

// Spaceship's Movements
enum SpaceshipMovement {
    case stopped, left, right
}

// Game's States
enum GameState: Int {
    case ready, gameOver, playing
}

// The categories of the game's objects for handling of the collisions
enum ColliderCategory: UInt32 {
    case spaceship = 1
    case enemy = 2
    case spaceshipBullet = 4
    case enemyBullet = 8
}


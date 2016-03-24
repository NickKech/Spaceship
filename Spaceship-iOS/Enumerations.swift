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
    case Background, Spaceship, Explosion, Hud, Message
}

// Spaceship's Movements
enum SpaceshipMovement {
    case Stopped, Left, Right
}

// Game's States
enum GameState: Int {
    case Ready, GameOver, Playing
}

// The categories of the game's objects for handling of the collisions
enum ColliderCategory: UInt32 {
    case Spaceship = 1
    case Enemy = 2
    case SpaceshipBullet = 4
    case EnemyBullet = 8
}


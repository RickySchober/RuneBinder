//
//  Player.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

import Foundation


struct Player{
    var currentHealth: Int
    var maxHealth: Int
    
    init(currentHealth: Int, maxHealth: Int) {
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
    }
}

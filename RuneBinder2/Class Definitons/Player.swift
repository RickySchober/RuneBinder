//
//  Player.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

import Foundation

struct Player: Identifiable, Entity{
    var debuffs: [Debuff]
    var currentHealth: Int
    var maxHealth: Int
    var ward: Int = 10
    var outlast: Int = 0
    var deflect: Int = 0
    var nullify: Int = 0
    let id = UUID()
    init(currentHealth: Int, maxHealth: Int) {
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
        debuffs = []
    }
    mutating func startUp() {
        if(outlast>0){
            outlast -= 1
        }
        else{
            ward = 0;
        }
    }
}
/* This protocol defines what values all entities such as players, enemies, and allies
 * must have for the purpose of visual representation in combat.
 */
protocol Entity{
    var debuffs: [Debuff] { get set }
    var currentHealth: Int { get set }
    var maxHealth: Int { get set }
    var ward: Int { get set }
}

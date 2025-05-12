//
//  Enemy.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/26/23.
//

import Foundation

struct Bleeds{
    var turns: Int
    var dmg: Int
}
class Enemy: Equatable, Identifiable{
    static func == (lhs: Enemy, rhs: Enemy) -> Bool {
        if(lhs.id==rhs.id){
            return true;
        }
        return false;
    }
    
    let maxHealth: Int
    var currentHealth: Int
    let position: Int
    var bleeds: [Bleeds]
    var image = "goblin2"
    var id: UUID
    enum actions {
        case nothing
    }
    init(pos: Int){
        maxHealth = 10
        currentHealth = maxHealth
        position = pos
        bleeds = []
        id = UUID()
    }
}
class Goblin: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "Rune2"
    }
}

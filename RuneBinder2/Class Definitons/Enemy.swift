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
    let hitSound = "goblinhit"
    let deathSound = "goblindeath"
    var image = "goblin2"
    var id: UUID
    var actions: [Action]
    var bleedDamage: Int {
        var temp = 0
        for bleed in bleeds {
            temp += bleed.dmg
        }
        return temp
    }
    
    init(pos: Int){
        maxHealth = 20
        currentHealth = maxHealth/2
        position = pos
        bleeds = [Bleeds(turns: 2, dmg: 2)]
        actions = [Action(dmg: 1)]
        id = UUID()
    }
    //Determines which action to take bassed on enemies selection algorithm
    func chooseAction(game: RuneBinderGame) -> Action{
        return actions[Int.random(in: 0...actions.count)]
    }
}
class Goblin: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "Rune2"
    }
}

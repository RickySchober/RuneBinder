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
    var image = "Rune2"
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
        maxHealth = 15
        currentHealth = maxHealth
        position = pos
        bleeds = [Bleeds(turns: 2, dmg: 2)]
        actions = [Action(dmg: 1)]
        id = UUID()
    }
    //Determines which action to take bassed on enemies selection algorithm
    func chooseAction(game: RuneBinderGame) -> Action{
        return actions[Int.random(in: 0...actions.count-1)]
    }
}
class Goblin: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "goblin2"
    }
}
class PoisonShroom: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "shroom"
        actions = [
            Action(dmg: 5),
            Action(dmg: 1, deb: [Debuff(type: .rot, value: 1),Debuff(type: .rot, value: 1)]),
        ]
    }
}
class RabidWolf: Enemy{
    var track: Int = 0
    override init(pos: Int) {
        super.init(pos: pos)
        image = "wolf"
        actions = [
            Action(dmg: 3),
            Action(dmg: 4),
            Action(dmg: 5),
            Action(dmg: 6),
        ]
    }
    override func chooseAction(game: RuneBinderGame) -> Action{
        track += 1
        if(track > actions.count-1){
            track = 0
        }
        return actions[track]
    }
}
class TorchBearer: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "torchbearer"
        actions = [
            Action(dmg: 7),
            Action(dmg: 0, deb: [Debuff(type: .scorch, value: 1),Debuff(type: .scorch, value: 1)]),
        ]
    }
}
class Tree: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "tree"
        actions = [
            Action(dmg: 8),
            Action(dmg: 0, deb: [Debuff(type: .rot, value: 5),Debuff(type: .scorch, value: 5)]),
        ]
    }
}
class ChainBearer: Enemy{
    override init(pos: Int) {
        super.init(pos: pos)
        image = "chainbearer"
        actions = [Action(dmg: 5, deb: [Debuff(type: .lock, value: 1), Debuff(type: .lock, value: 1), Debuff(type: .weak, value: 1)])]
    }
}
//Biome ideas Phonetic Forest, Glyph Mines, Ancient Archive, Citadel

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
    
    init(){
        maxHealth = 15
        currentHealth = maxHealth
        bleeds = [Bleeds(turns: 2, dmg: 2)]
        actions = [Action(dmg: 1)]
        id = UUID()
    }
    //Determines which action to take bassed on enemies selection algorithm defualt is random
    func chooseAction(game: RuneBinderGame) -> Action{
        return actions[Int.random(in: 0...actions.count-1)]
    }
}

extension Enemy { //Converts class into codable struct for storage
    func toData() -> EnemyData {
        EnemyData(
            id: self.id,
            enemyName: String(describing: type(of: self))
        )
    }
}

class Goblin: Enemy{
    override init() {
        super.init()
        image = "goblin2"
    }
}
class GoblinShaman: Enemy{
    override init() {
        super.init()
        image = "goblin2"
        actions = [
            Action(dmg: 4),
            Action(dmg: 3, deb: [Debuff(archetype: .weak, value: 1),Debuff(archetype: .rot, value: 1)]),
            Action(dmg: 1, deb: [Debuff(archetype: .weak, value: 3),Debuff(archetype: .rot, value: 3)]),
        ]
    }
}
class PoisonShroom: Enemy{
    override init() {
        super.init()
        image = "shroom"
        actions = [
            Action(dmg: 5),
            Action(dmg: 1, deb: [Debuff(archetype: .rot, value: 1),Debuff(archetype: .rot, value: 1)]),
        ]
    }
}
class MultiplyingMycospawn: Enemy{
    override init() {
        super.init()
        image = "shroom"
        actions = [
            Action(dmg: 3),
            Action(dmg: 1, deb: [Debuff(archetype: .rot, value: 1)]),
            SummonAction(nm:"Rapid Reproduction", summons: ["MultiplyingMycospawn"])
        ]
    }
    override func chooseAction(game: RuneBinderGame) -> Action{
        if(Double(currentHealth)/Double(maxHealth)<0.5){
            return actions[actions.count-1]
        }
        else{
            return actions[Int.random(in: 0...actions.count-2)]
        }        
    }
}
class RabidWolf: Enemy{
    var track: Int = 0
    override init() {
        super.init()
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
class WolfPackLeader: Enemy{
    var track: Int = 0
    override init() {
        super.init()
        image = "wolf"
        actions = [
            Action(dmg: 7),
            SummonAction(nm:"Call of the Hunt", summons: ["RabidWolf","RabidWolf"])
        ]
    }
    override func chooseAction(game: RuneBinderGame) -> Action{
        if(game.enemies.count<=2 && track >= 3){
            track = 0
            return actions[actions.count-1]
        }
        else{
            track += 1
            return actions[Int.random(in: 0...actions.count-2)]
        }
        
    }
}
class TorchBearer: Enemy{
    override init() {
        super.init()
        image = "torchbearer"
        actions = [
            Action(dmg: 7),
            Action(dmg: 0, deb: [Debuff(archetype: .scorch, value: 1),Debuff(archetype: .scorch, value: 1)]),
        ]
    }
}
class Tree: Enemy{
    override init() {
        super.init()
        image = "tree"
        actions = [
            Action(dmg: 8),
            Action(dmg: 0, deb: [Debuff(archetype: .rot, value: 5),Debuff(archetype: .scorch, value: 5)]),
        ]
    }
}
class ChainBearer: Enemy{
    override init() {
        super.init()
        image = "chainbearer"
        actions = [Action(dmg: 5, deb: [Debuff(archetype: .lock, value: 1), Debuff(archetype: .lock, value: 1), Debuff(archetype: .weak, value: 1)])]
    }
}
//Biome ideas Phonetic Forest, Glyph Mines, Ancient Archive, Citadel

//
//  Enemy.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/26/23.
//

import Foundation

class Enemy: Entity, Equatable{
    static func == (lhs: Enemy, rhs: Enemy) -> Bool {
        if(lhs.id==rhs.id){
            return true;
        }
        return false;
    }
    let hitSound = "goblinhit"
    let deathSound = "goblindeath"
    var image = "Rune2"
    var actions: [Action]
    var chosenAction: Action? = nil
    
    override init(){
        actions = [Action(dmg: 1)]
        super.init()
        maxHealth = 15
        currentHealth = maxHealth
    }
    //Determines which action to take bassed on enemies selection algorithm default is random
    func chooseAction(game: RuneBinderGame){
        chosenAction = actions[Int.random(in: 0...actions.count-1)]
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
// Goblin forest
class GoblinGrunt: Enemy{
    override init() {
        super.init()
        image = "goblin_grunt"
        maxHealth = 8
        currentHealth = maxHealth
        actions = [
            Action(nm: "Sword Strike", dmg: 4),
            Action(nm: "Block", grd: 6 ),
        ]
    }
}
class GoblinImp: Enemy{
    override init() {
        super.init()
        image = "goblin_imp"
        maxHealth = 6
        currentHealth = maxHealth
        actions = [
            Action(nm: "Pathetic Punch", dmg: 2),
            Action(nm: "Pyromanic", runeDeb: [RuneDebuff(archetype: .scorch, value: 2), RuneDebuff(archetype: .scorch, value: 2)]),
            Action(nm: "Cower", grd: 3 ),
        ]
    }
}
class GoblinShaman: Enemy{
    override init() {
        super.init()
        image = "goblin_shaman3"
        maxHealth = 10
        currentHealth = maxHealth
        actions = [
            Action(nm: "Staff Bonk", dmg: 4),
            Action(nm: "Block", grd: 4 ),
            Action(nm: "Weakening Curse", runeDeb: [RuneDebuff(archetype: .weak, value: 2),RuneDebuff(archetype: .weak, value: 2)]),
        ]
    }
}
class GoblinBrawler: Enemy{
    override init() {
        super.init()
        image = "goblin_brawler"
        maxHealth = 13
        currentHealth = maxHealth
        actions = [
            Action(nm: "Right Hook", dmg: 6),
            Action(nm: "Defensive Stance", grd: 8 ),
            Action(nm: "Grapple", dmg: 4, runeDeb: [RuneDebuff(archetype: .lock, value: 3)]),
        ]
    }
}
class GoblinBrute: Enemy{
    var track: Int = 0
    override init() {
        super.init()
        image = "goblin_brute"
        maxHealth = 20
        currentHealth = maxHealth
        actions = [
            Action(nm: "Right Hook", dmg: 6),
            Action(nm: "Devastating Strike", dmg: 16),
            Action(nm: "Rest"),
            Action(nm: "Gaurd", dmg: 4),
        ]
    }
    override func chooseAction(game: RuneBinderGame) {
        if(track >= actions.count){
            track = 0
        }
        let chosen = actions[track]
        track += 1
        chosenAction = chosen
    }
}

class PoisonShroom: Enemy{
    override init() {
        super.init()
        image = "shroom"
        actions = [
            Action(dmg: 5),
            Action(dmg: 1, runeDeb: [RuneDebuff(archetype: .rot, value: 1),RuneDebuff(archetype: .rot, value: 1)]),
        ]
    }
}
class MultiplyingMycospawn: Enemy{
    override init() {
        super.init()
        image = "goblintrans"
        actions = [
            Action(dmg: 3),
            Action(dmg: 1, runeDeb: [RuneDebuff(archetype: .rot, value: 1)]),
            SummonAction(nm:"Rapid Reproduction", summons: ["MultiplyingMycospawn"])
        ]
    }
    override func chooseAction(game: RuneBinderGame){
        if(Double(currentHealth)/Double(maxHealth)<0.5){
            chosenAction = actions[actions.count-1]
        }
        else{
            chosenAction = actions[Int.random(in: 0...actions.count-2)]
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
    override func chooseAction(game: RuneBinderGame){
        track += 1
        if(track > actions.count-1){
            track = 0
        }
        chosenAction = actions[track]
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
    override func chooseAction(game: RuneBinderGame){
        if(game.enemies.count<=2 && track >= 3){
            track = 0
            chosenAction = actions[actions.count-1]
        }
        else{
            track += 1
            chosenAction = actions[Int.random(in: 0...actions.count-2)]
        }
        
    }
}
class TorchBearer: Enemy{
    override init() {
        super.init()
        image = "torchbearer"
        actions = [
            Action(dmg: 7),
            Action(dmg: 0, runeDeb: [RuneDebuff(archetype: .scorch, value: 1),RuneDebuff(archetype: .scorch, value: 1)]),
        ]
    }
}
class Tree: Enemy{
    override init() {
        super.init()
        image = "tree"
        actions = [
            Action(dmg: 8),
            Action(dmg: 0, runeDeb: [RuneDebuff(archetype: .rot, value: 5),RuneDebuff(archetype: .scorch, value: 5)]),
        ]
    }
}
class ChainBearer: Enemy{
    override init() {
        super.init()
        image = "chainbearer"
        actions = [Action(dmg: 5, runeDeb: [RuneDebuff(archetype: .lock, value: 1), RuneDebuff(archetype: .lock, value: 1), RuneDebuff(archetype: .weak, value: 1)])]
    }
}
//Biome ideas Phonetic Forest, Glyph Mines, Ancient Archive, Citadel

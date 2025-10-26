//
//  Player.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

import Foundation

class Player: Entity{
    var actions: Int = 2
    init(currentHealth: Int, maxHealth: Int) {
        super.init()
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
        debuffs = []
        buffs = []
    }
}
/* This class defines what values all entities such as players, enemies, and allies
 * must have for the purpose of visual representation in combat.
 */
class Entity: Identifiable{
    var debuffs: [Debuff] = []
    var buffs: [Buff] = []
    var currentHealth: Int = 0
    var maxHealth: Int = 0
    var ward: Int = 0
    var id = UUID()
    func takeDamage(hit: Int, ignoreWard: Bool = false) -> Int{ //Returns damage done to health
        let frail: Bool = debuffs.contains { $0.archetype == .frail }
        let damage: Int = Int(Double(hit) * (frail ? 1.5 : 1.0))
        let oldHealth: Int = currentHealth
        if(!ignoreWard && !(ward == 0)){
            currentHealth = min(0, currentHealth - min(0, damage - ward)  ) //leftover damage to health
            ward = max(0, ward - damage)
        }
        else{
            currentHealth = max(0, currentHealth - damage)
        }
        return oldHealth - currentHealth
    }
    func triggerDebuffs() -> [CombatEvent]{ //Returns all animations regarding debuffs triggering on turns end
        var animations: [CombatEvent] = []
        for i in debuffs.indices {
            switch debuffs[i].archetype{
            case .bleed:
                let temp = takeDamage(hit: debuffs[i].value)
                animations.append(.damage(id: id, amount: temp, delay: 0.5))
            case .frail: break
            case .stun: break
            }
            debuffs[i].value -= 1
            if(debuffs[i].value<=0){
                debuffs.remove(at: i)
            }
        }
        return animations
    }
    func triggerBuffs(){ //Resolve all buffs on turns start
        if(!(buffs.contains { $0.archetype == .outlast})){
            ward = 0;
        }
        for i in buffs.indices{
            buffs[i].value -= 1
            if(buffs[i].value <= 0){
                buffs.remove(at: i)
            }
        }
    }
    func applyDebuff(debuff: Debuff){
        if let index = debuffs.firstIndex(where: { $0.archetype == debuff.archetype }) {
                debuffs[index].value += debuff.value
            } else {
                debuffs.append(debuff)
            }
    }
    func applyBuff(buff: Buff){
        if let index = buffs.firstIndex(where: { $0.archetype == buff.archetype }) {
                buffs[index].value += buff.value
            } else {
                buffs.append(buff)
            }
    }
}

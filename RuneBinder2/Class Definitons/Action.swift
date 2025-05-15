/*
    Defines enemy actions
 */
import Foundation

class Action{
    let name: String
    let damage: Int
    //Debuffs to be applied default 0
    let rot: Int
    let scorch: Int
    let lock: Int
    let weaken: Int
    init(nm: String = "Bonk", dmg: Int = 0, rt: Int = 0, sch: Int = 0, lck: Int = 0, wek: Int = 0){
        name = nm
        damage = dmg
        rot = rt
        scorch = sch
        lock = lck
        weaken = wek
    }
    func utilizeEffect(game: RuneBinderGame){ //Additional effects beyond the basic action
    }
}


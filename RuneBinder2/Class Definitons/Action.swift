/*
    Defines enemy actions
 */
import Foundation

class Action{
    let name: String
    let damage: Int
    let debuffs: [Debuff]
    init(nm: String = "Bonk", dmg: Int = 0, deb: [Debuff] = []){
        name = nm
        damage = dmg
        debuffs = deb
    }
    func utilizeEffect(game: RuneBinderGame){ //Additional effects beyond the basic action
    }
}


/*
    Defines enemy actions
 */
import Foundation

//Generic action that deals damage, shields self, and/or debuffs player
class Action{
    let name: String
    let damage: Int
    let debuffs: [RuneDebuff]
    let gaurd: Int
    init(nm: String = "Bonk", dmg: Int = 0, grd: Int = 0, deb: [RuneDebuff] = []){
        name = nm
        damage = dmg
        debuffs = deb
        gaurd = grd
    }
    func utilizeEffect(game: RuneBinderGame){ //Additional effects beyond the basic action
    }
}
//Actions that summon additional units if there is space. Take in array of units to summon as input
class SummonAction: Action {
    var factories: [() -> Enemy]
    init(nm: String = "Bonk", dmg: Int = 0, deb: [RuneDebuff] = [], summons: [String]){
        factories = summons.compactMap { enemy in //Map string to function which generates an enemy of same name
            enemyFactory[enemy]
        }
        super.init(nm: nm, dmg: dmg, deb: deb)
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.addEnemies(newEnemies: factories.map { $0() }, pos: 0) //execute close to instantiate enemy objects
    }
}
//Actions that apply buffs to enemies.
class BuffAction: Action {
    
    override init(nm: String = "Bonk", dmg: Int = 0, grd: Int = 0, deb: [RuneDebuff] = []) {
    }
    override func utilizeEffect(game: RuneBinderGame) {
    }
}


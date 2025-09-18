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
class SummonAction: Action {
    var factories: [() -> Enemy]
    init(nm: String = "Bonk", dmg: Int = 0, deb: [Debuff] = [], summons: [String]){
        factories = summons.compactMap { enemy in //Map string to function which generates an enemy of same name
            enemyFactory[enemy]
        }
        super.init(nm: nm, dmg: dmg, deb: deb)
        
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.addEnemies(newEnemies: factories.map { $0() }, pos: 0) //execute close to instantiate enemy objects
    }
}


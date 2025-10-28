/*
    Defines enemy actions
 */
import Foundation

//Generic action that deals damage, shields self, and/or debuffs player
class Action{
    let name: String
    let damage: Int
    let runeDebuffs: [RuneDebuff]
    let debuffs: [Debuff]
    let gaurd: Int
    init(nm: String = "Bonk", dmg: Int = 0, grd: Int = 0, deb: [Debuff] = [], runeDeb: [RuneDebuff] = []){
        name = nm
        damage = dmg
        debuffs = deb
        gaurd = grd
        runeDebuffs = runeDeb
    }
    func utilizeEffect(game: RuneBinderGame){ //Additional effects beyond the basic action
    }
}
//Actions that summon additional units if there is space. Take in array of units to summon as input
class SummonAction: Action {
    var factories: [() -> Enemy]
    init(nm: String = "Bonk", dmg: Int = 0, grd: Int = 0, deb: [Debuff] = [], runeDeb: [RuneDebuff] = [], summons: [String]){
        factories = summons.compactMap { enemy in //Map string to function which generates an enemy of same name
            enemyFactory[enemy]
        }
        super.init(nm: nm, dmg: dmg, deb: deb, runeDeb: runeDeb)
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.addEnemies(newEnemies: factories.map { $0() }, pos: 0) //execute close to instantiate enemy objects
    }
}
//Actions that apply buffs to enemies.
class BuffAction: Action {
    
    override init(nm: String = "Bonk", dmg: Int = 0, grd: Int = 0, deb: [Debuff] = [], runeDeb: [RuneDebuff] = []) {
    }
    override func utilizeEffect(game: RuneBinderGame) {
    }
}


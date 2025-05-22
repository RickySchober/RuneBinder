//
//  Enchantment.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

/*
    Enchantments are tied to different runes that activate when spelled in a word. Rune effects must
 either be persistent effects that add to the cast spell function or be queued to activate in a certain order
 Potentially implement highlight that shows what will happen when spell is cast.
 */
import Foundation
import SwiftUI
class Enchantment{
    enum rarity{
        case uncommon
        case rare
        case legendary
    }
    enum type{
        case bloodletting
        case destruction
        case disruption
        case preservation
    }
    /*Enchantment priority goes from the lowest priority of 0 to highest priority
     enchants of same priority should be able to be used in any order without affecting the outcome
     Priority 0: spell power effects
     Priority 1: enemy targeting effects
     Priority 2: leech, block, debuffs or anything effected by targets and spell power
     Priority 3: unmodifiable effects
     Priority 4: post damage effects that modify grid (surge purify)
     */
    var priority: Int
    var color: Color
    var description: String
    required init() {
        priority = 3
        color = Color.yellow
        description = "Enchantment: Increases spell power of rune by 1"
    }
    
    func utilizeEffect(game: RuneBinderGame){
    }
   
}
class Empower: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Revitalize: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class Cleave: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 1
        color = Color.gray
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!.position+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!.position+1]);
        }
        else if(game.primaryTarget!.position-1>=0){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!.position-1]);
        }
    }
}
class VampiricStrike: Enchantment{
    var rarity = rarity.rare
    var type = type.bloodletting
    required init() {
        super.init()
        priority = 2
        color = Color.red
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: game.getSpellPower())
    }
}
class SerratedStrike: Enchantment{
    var rarity = rarity.uncommon
    var type = type.bloodletting
    required init() {
        super.init()
        priority = 2
        color = Color.red
    }
    override func utilizeEffect(game: RuneBinderGame){
        for target in game.targets{
            target.bleeds.append(Bleeds(turns: 3, dmg: 1))
        }
    }
}



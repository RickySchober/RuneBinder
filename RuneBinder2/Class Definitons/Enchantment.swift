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

class Enchantment: Equatable, Identifiable{
    static func == (lhs: Enchantment, rhs: Enchantment) -> Bool {
        return lhs.description == rhs.description
    }
    
    enum rarity{
        case uncommon
        case rare
        case legendary
    }
    enum type{
        case hex
        case destruction
        case manipulation
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
    var id = UUID()
    required init() {
        priority = 3
        color = Color.yellow
        description = "Enchantment: Increases spell power of rune by 1"
    }
    
    func utilizeEffect(game: RuneBinderGame){
    }
   
}
/*
    Destruction: modify spell power and enchantments
 */
class Empower: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Empower: Increases spell power of rune by 1"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Enlarge: Enchantment{
    var rarity = rarity.rare
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Enlarge: Increases spell power by 1 for each rune following this one"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Swarm: Enchantment{
    var rarity = rarity.rare
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Swarm: Increases spell power by 2 for each other letter matching this rune"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Magnify: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Magnify: Double enchanted runes spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Diversify: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Diversify: This rune counts as all runes for purposes of spelling and bonuses"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Replicate: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Replicate: Draw a temporary copy of an enchantment used in spell (ignoring enchantment limit)"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Expidite: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Expidite: Draw an additional enchantment (ignoring enchantment limit)"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Restart: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Restart: Reshuffle your enchantment deck before drawing new runes"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Foresee: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Forsee: This rune gains the effect of the next enchantment in your deck"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Rewrite: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Rewrite: Discard up to 3 enchantments from the top of your deck"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Master: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.blue
        description = "Master: Draw an additional enchantment for each other destruction rune used in spell (maximum of 2 ignoring enchantment limit)"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}




/*
    Preservation: healing, cleansing, ward
 */
class Revitalize: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Revitalize: Heal up to 4 hitpoints"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class Ward: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Ward: Gain 10 block"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 10
    }
}
class Outlast: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Outlast: Gain 8 block, block is not removed for 1 turn"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 8
        game.player.outlast += 1
    }
}
class Brace: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Brace: Gain 7 block for each enemy"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 7*game.enemies.count
    }
}
class Deflect: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Deflect: Gain 9 block, until your next turn damage dealt to your block is reflected back to attackers"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 9
        game.player.deflect += 1
    }
}
class Fortify: Enchantment{
    var rarity = rarity.rare
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Fortify: Gain block equal to twice your spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 8
        game.player.outlast += 1
    }
}
class Nullify: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Nullify: Gain 1 nullify preventing debuffs from the next attack that applies debuffs"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.nullify += 1
    }
}
class Purity: Enchantment{
    var rarity = rarity.rare
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Purity: For the rest of combat gain 1 nullify whenever you are afflicted by a debuff"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.nullify += 1
    }
}
class Purify: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Purify: remove up to 2 rune debuffs"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class Ignorance: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Ignorance: ignore all debuff affects"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class CleansingWave: Enchantment{
    var rarity = rarity.rare
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Cleansing Wave: remove all debuffs on player and runes"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for rune in game.grid{
            rune.debuff = nil
        }
    }
}
/*
    Manipulation: Change the targeting of the spell often modifying spell power
 */
class Cleave: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Cleave: hits enemies on either side of target but halves spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1]);
        }
        else if(game.primaryTarget!-1>=0){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1]);
        }
        game.changeSpellPower(num: -game.getSpellPower()/2)
    }
}
class Snowball: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Snowball: hits all enemies behind the target increasing spell power as it grows"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1]);
        }
        else if(game.primaryTarget!-1>=0){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1]);
        }
        game.changeSpellPower(num: -game.getSpellPower()/2)
    }
}
class Gatling: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Gatling: hits a random enemy 5 times dealing a quarter spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: -game.getSpellPower()/2)
    }
}
class Shotgun: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Shotgun: hits closest enemy for x2 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: -game.getSpellPower()/2)
    }
}
class Lob: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Lob: hits furthest enemy for x1.5"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: -game.getSpellPower()/2)
    }
}

/*
    Hex: Apply curses debuffing enemies and unique effects
 */
class VampiricStrike: Enchantment{
    var rarity = rarity.rare
    var type = type.hex
    required init() {
        super.init()
        priority = 2
        color = Color.red
        description = "Vampiric Strike: heal based on damage done"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: game.getSpellPower())
    }
}
class SerratedStrike: Enchantment{
    var rarity = rarity.uncommon
    var type = type.hex
    required init() {
        super.init()
        priority = 2
        color = Color.red
        description = "Serrated Strike: apply 3 bleed to all enemies hit"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for target in game.targets{
            game.enemies[target].bleeds.append(Bleeds(turns: 3, dmg: 1))
        }
    }
}
class Discombobulate: Enchantment{
    var rarity = rarity.uncommon
    var type = type.hex
    required init() {
        super.init()
        priority = 2
        color = Color.red
        description = "Build: up stun power based on damage dealt"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for target in game.targets{
            game.enemies[target].bleeds.append(Bleeds(turns: 3, dmg: 1))
        }
    }
}
class Cripple: Enchantment{
    var rarity = rarity.uncommon
    var type = type.hex
    required init() {
        super.init()
        priority = 2
        color = Color.red
        description = "Cripple: apply 1 frail to enemies hit"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for target in game.targets{
            game.enemies[target].bleeds.append(Bleeds(turns: 3, dmg: 1))
        }
    }
}
class Pierce: Enchantment{
    var rarity = rarity.uncommon
    var type = type.hex
    required init() {
        super.init()
        priority = 2
        color = Color.red
        description = "Pierce: spell damage ignores enemy block"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for target in game.targets{
            game.enemies[target].bleeds.append(Bleeds(turns: 3, dmg: 1))
        }
    }
}

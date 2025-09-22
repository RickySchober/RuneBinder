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
        case common //starting deck cards not found in runs
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
     Priority 0: augment spell power effects and unmodifiable effects
     Priority 1: forced targeting
     Priority 2: augmented targeting
     Priority 3: spell power and targeting based effects
     Priority 4: post damage effects
     */
    var priority: Int
    var color: Color
    var description: String
    var id = UUID()
    required init() {
        priority = 4
        color = Color.yellow
        description = "Enchantment: Wow so shiny"
    }
    
    func utilizeEffect(game: RuneBinderGame){
    }
   
}
/*
    Destruction: modify spell power and enchantments
 */
class Empower: Enchantment{
    var rarity = rarity.common
    var type = type.destruction
    required init() {
        super.init()
        priority = 0
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
        priority = 0
        color = Color.blue
        description = "Enlarge: Increases spell power by 1 for each rune following this one"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for i in 0..<game.spell.count{
            if(game.spell[i].enchant == self){
                game.changeSpellPower(num: game.spell.count-i-1)
            }
        }
        
        
    }
}
class Swarm: Enchantment{
    var rarity = rarity.rare
    var type = type.destruction
    required init() {
        super.init()
        priority = 0
        color = Color.blue
        description = "Swarm: Increases spell power by 2 for each other letter matching this rune"
    }
    override func utilizeEffect(game: RuneBinderGame){
        guard let associatedRune = game.spell.first(where: { $0.enchant == self }) else { //Rune should be found otherwise exit
            return
        }
        for rune in game.spell {
            if rune != associatedRune && rune.letter == associatedRune.letter {
                game.changeSpellPower(num: 2)
            }
        }

    }
}
class Magnify: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 0
        color = Color.blue
        description = "Magnify: Double enchanted runes spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for rune in game.spell{
            if(rune.enchant == self){
                game.changeSpellPower(num: rune.power)
            }
        }
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
        priority = 4
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
        priority = 4
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
        priority = 4
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
        priority = 4
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
        priority = 4
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
    var rarity = rarity.common
    var type = type.preservation
    required init() {
        super.init()
        priority = 0
        color = Color.green
        description = "Revitalize: Heal up to 3 hitpoints"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 3)
    }
}
class Ward: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    required init() {
        super.init()
        priority = 0
        color = Color.green
        description = "Ward: Gain 5 block"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 5
    }
}
class Outlast: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 0
        color = Color.green
        description = "Outlast: Gain 6 block, block is not removed for 1 turn"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 6
        game.player.outlast += 1
    }
}
class Brace: Enchantment{
    var rarity = rarity.uncommon
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 0
        color = Color.green
        description = "Brace: Gain 4 block for each enemy"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += 4*game.enemies.count
    }
}
class Deflect: Enchantment{
    var rarity = rarity.rare
    var type = type.preservation
    
    required init() {
        super.init()
        priority = 0
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
        priority = 3
        color = Color.green
        description = "Fortify: Gain block equal to twice your spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += game.spellPower * 2
    }
}
class Nullify: Enchantment{
    var rarity = rarity.common
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
    var rarity = rarity.rare
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Ignorance: ignore all debuff effects for 1 turn"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class CleansingWave: Enchantment{
    var rarity = rarity.legendary
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
class Pacifism: Enchantment{
    var rarity = rarity.legendary
    var type = type.preservation
    required init() {
        super.init()
        priority = 2
        color = Color.green
        description = "Pacifism: "
    }
    override func utilizeEffect(game: RuneBinderGame){
        for rune in game.grid{
            rune.debuff = nil
        }
    }
}
/*
    Manipulation: Change the targeting of the spell often modifying damage dealt as a fraction spell power.
    All manipulation enchantments can be combined to varying effect.
    Forced targeting sets primary target ignoring user selection (priority 1).
    Augmented targeting adds additional targets beyond primary (priority 2).
    Multiple forced targets will use right most one in spell ignoring others.
    Multiple augments should be compatible with eachother only adding with respect to primary target
 */
class Extend: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Extend: splits damage to enemy behind target for x2/3 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: 0.6666);
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: 0.6666)
    }
}
class Expand: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Extend: splits damage to enemies on either side of target for x1/3 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: 0.3333);
        }
        if(game.primaryTarget!-1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1], modifier: 0.3333);
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: 0.3333)
    }
}
class Engulf: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Engulf: splits damage to all other enemies for a x1/4 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for i in 0..<game.enemies.count{
            game.addTarget(enemy: game.enemies[i], modifier: 0.25)
        }
    }
}
class Isolate: Enchantment{
    var rarity = rarity.uncommon
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Isolate: hits enemies on either side instead of target for x3/4 of spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: 0.75);
        }
        if(game.primaryTarget!-1>=0){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1], modifier: 0.75);
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: -game.targets[game.primaryTarget!])
    }
}
class Gatling: Enchantment{
    var rarity = rarity.legendary
    var type = type.manipulation
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Gatling: splits damage among 5 random targets dealing a x1/4 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for _ in 0..<5{
            var rand = Int.random(in: 0..<game.targets.count)
            game.addTarget(enemy: game.enemies[rand], modifier: 0.25)
        }
    }
}
class Eliminate: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Eliminate: hits the lowest health enemy ignoring target for x1.5 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        var smallest: Enemy = game.enemies[0]
        for enemy in game.enemies{
            if(enemy.currentHealth<smallest.currentHealth){
                smallest = enemy
            }
        }
        game.changeTarget(enemy: smallest, modifier: 1.5)
    }
}
class Aspire: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Aspire: hits the highest health enemy ignoring target for x2 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        var biggest: Enemy = game.enemies[0]
        for enemy in game.enemies{
            if(enemy.currentHealth>biggest.currentHealth){
                biggest = enemy
            }
        }
        game.changeTarget(enemy: biggest, modifier: 2.0)
    }
}
class Randomize: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Randomize: hits a random enemy ignoring target for x2.5 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[Int.random(in:0..<game.enemies.count)], modifier: 2.5)
    }
}
class Shotgun: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Shotgun: hits closest enemy ignoring target for x2 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[0], modifier: 2.0)
    }
}
class Lob: Enchantment{
    var rarity = rarity.rare
    var type = type.manipulation
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        description = "Lob: hits furthest enemy ignoring target for x1.5 spell power"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[game.enemies.count-1], modifier: 1.5)
    }
}
class Enclose: Enchantment{
    var rarity = rarity.legendary
    var type = type.destruction
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Enclose: hits for x2 spell power if one enemy remains and x1/2 spell power otherwise"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.enemies.count>1){
            for i in 0..<game.targets.count{
                game.addTarget(enemy: game.enemies[i], modifier: -game.targets[i]/2)
            }
        }
        else{
            game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: 2.0)
        }
    }
}
class Snowball: Enchantment{
    var rarity = rarity.legendary
    var type = type.manipulation
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        description = "Snowball: also hits all enemies behind the target increasing spell power as it grows"
    }
    override func utilizeEffect(game: RuneBinderGame){
        var inc: Int = 1
        while(game.primaryTarget! + inc < game.enemies.count){
            game.addTarget(enemy: game.enemies[game.primaryTarget!+inc], modifier: 0.333*Double(inc))
        }
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
        for i in 0..<game.targets.count{
            if(game.targets[i]>0.0){ //If enemy is being hit
                game.enemies[i].bleeds.append(Bleeds(turns: 3, dmg: 1))
            }
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
        for i in 0..<game.targets.count{
            if(game.targets[i]>0.0){ //If enemy is being hit
                game.enemies[i].bleeds.append(Bleeds(turns: 3, dmg: 1))
            }
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
        for i in 0..<game.targets.count{
            if(game.targets[i]>0.0){ //If enemy is being hit
                game.enemies[i].bleeds.append(Bleeds(turns: 3, dmg: 1))
            }
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
    }
}

//
//  Enchantment.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

/*
    Enchantments are tied to different runes that activate when spelled in a word. Rune effects must
 either be persistent effects that add to the cast spell function or be queued to activate in a certain order
 Potentially implement highlight that shows what will happen when spell is cast. They should be named as verbs
 */
import Foundation
import SwiftUI


class Enchantment: Equatable, Identifiable{
    static func == (lhs: Enchantment, rhs: Enchantment) -> Bool {
        return lhs.description == rhs.description
    }
    
    enum rarity: String, Codable{
        case common, uncommon, rare, legendary
    }
    enum archetype: String, Codable{
        case hex, destruction, manipulation, preservation
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
    var description: String {
        "Empower: Increases spell power of rune by \(upgraded ? 2 : 1)"
    }
    var id = UUID()
    var upgraded: Bool
    var image: String
    required init() {
        priority = 4
        color = Color.yellow
        upgraded = false
        image = "empower"
    }
    
    func utilizeEffect(game: RuneBinderGame){
    }
}
extension Enchantment { //Converts class into codable struct for storage
    func toData() -> EnchantmentData {
        EnchantmentData(
            id: self.id,
            enchantName: String(describing: type(of: self)),
            upgraded: self.upgraded
        )
    }
}


/*
    Destruction: modify spell power and enchantments
 */
class Empower: Enchantment{
    var rarity = rarity.common
    var archetype = archetype.destruction
    override var description: String {
        "Empower: Increases spell power of rune by \(upgraded ? 2 : 1)"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: (upgraded) ? 2 : 1)
        
    }
}
class Enlarge: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.destruction
    override var description: String {
        "Enlarge: Increases spell power by 1 for \(upgraded ? "this rune and " : "")each rune following this one"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        for i in 0..<game.spell.count{
            if(game.spell[i].enchant == self){
                game.changeSpellPower(num: game.spell.count-i-(upgraded ? 0 : 1))
            }
        }
        
        
    }
}
class Swarm: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.destruction
    override var description: String {
        "Swarm: Increases spell power by \(upgraded ? 3 : 2) for each other letter matching this rune"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        guard let associatedRune = game.spell.first(where: { $0.enchant == self }) else { //Rune should be found otherwise exit
            return
        }
        for rune in game.spell {
            if rune != associatedRune && rune.letter == associatedRune.letter {
                game.changeSpellPower(num: (upgraded ? 3 : 2))
            }
        }

    }
}
class Magnify: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Magnify: \(upgraded ? "triple" : "double") enchanted runes spell power"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        for rune in game.spell{
            if(rune.enchant == self){
                game.changeSpellPower(num: (upgraded ? 2 : 1)*rune.power)
            }
        }
    }
}
class Diversify: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Diversify: This rune counts as all runes for purposes of spelling \(upgraded ? "and bonuses" : "")"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Replicate: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Replicate: Draw a\(upgraded ? "n upgraded " : " ")temporary copy of an enchantment used in spell (ignoring enchantment limit)"
    }
    required init() {
        super.init()
        priority = 4
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
        
    }
}
class Expidite: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Expidite: Draw \(upgraded ? 2 : 1) additional enchantment (ignoring enchantment limit)"
    }
    required init() {
        super.init()
        priority = 4
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Restart: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Restart: \(upgraded ? "Heal 4 and" : "") Reshuffle your enchantment deck before drawing new runes"
    }
    required init() {
        super.init()
        priority = 4
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Foresee: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Forsee: This rune gains the effect of the next enchantment in your deck \(upgraded ? "twice" : "")"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Rewrite: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Rewrite: Discard up to \(upgraded ? 5 : 3) enchantments from the top of your deck"
    }
    required init() {
        super.init()
        priority = 4
        color = Color.blue
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeSpellPower(num: 1)
    }
}
class Master: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Master: Draw an additional enchantment for each other destruction rune used in spell (maximum of \(upgraded ? 3 : 2) ignoring enchantment limit)"
    }
    required init() {
        super.init()
        priority = 4
        color = Color.blue
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
    var archetype = archetype.preservation
    override var description: String {
        "Revitalize: Heal up to \(upgraded ? 5 : 3) hitpoints"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.green
        image = "revitalize"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: (upgraded ? 5 : 3))
    }
}
class Ward: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.preservation
    override var description: String {
        "Ward: Gain \(upgraded ? 8 : 5) block"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.green
        image = "ward"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += (upgraded ? 8 : 5)
    }
}
class Outlast: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.preservation
    override var description: String {
        "Outlast: Gain \(upgraded ? 9 : 6) block, block is not removed for 1 turn"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += (upgraded ? 9 : 6)
        game.player.outlast += 1
    }
}
class Brace: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.preservation
    override var description: String {
        "Brace: Gain \(upgraded ? 6 : 4) block for each enemy"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += (upgraded ? 6 : 4)*game.enemies.count
    }
}
class Deflect: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.preservation
    override var description: String {
        "Deflect: Gain \(upgraded ? 11 : 9) block, until your next turn damage dealt to your block is reflected back to attackers"
    }
    required init() {
        super.init()
        priority = 0
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += (upgraded ? 11 : 9)
        game.player.deflect += 1
    }
}
class Fortify: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.preservation
    override var description: String {
        "Fortify: Gain block equal to\(upgraded ? " twice" : "") your spell power"
    }
    required init() {
        super.init()
        priority = 3
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.block += game.spellPower * (upgraded ? 2 : 1)
    }
}
class Nullify: Enchantment{
    var rarity = rarity.common
    var archetype = archetype.preservation
    override var description: String {
        "Nullify: Gain \(upgraded ? 2 : 1) nullify preventing debuffs from the next attack that applies debuffs"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.nullify += (upgraded ? 2 : 1)
    }
}
class Purity: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.preservation
    override var description: String {
        "Purity: For the rest of combat gain \(upgraded ? 2 : 1) nullify whenever you are afflicted by a debuff"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.player.nullify += 1
    }
}
class Purify: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.preservation
    override var description: String {
        "Purify: remove up to \(upgraded ? 3 : 2) rune debuffs"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class Ignorance: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.preservation
    override var description: String {
        "Ignorance: ignore all debuff effects for \(upgraded ? 2 : 1) turn"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeHealth(num: 5)
    }
}
class CleansingWave: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.preservation
    override var description: String {
        "Cleansing Wave: remove all debuffs on player and runes\(upgraded ? " gain 5 health" : "")"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
    }
    override func utilizeEffect(game: RuneBinderGame){
        for rune in game.grid{
            rune.debuff = nil
        }
    }
}
class Pacifism: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.preservation
    override var description: String {
        "Pacifism: "
    }
    required init() {
        super.init()
        priority = 2
        color = Color.green
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
    var archetype = archetype.destruction
    override var description: String {
        "Extend: splits damage to enemy behind target for x\(upgraded ? "2/3" : "1/2") spell power"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "extand"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: (upgraded ? 0.6666 : 0.5));
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: (upgraded ? 0.6666 : 0.5))
    }
}
class Expand: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.destruction
    override var description: String {
        "Expand: splits damage to enemies on either side of target for x\(upgraded ? "1/2" : "1/3") spell power"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "expand"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: (upgraded ? 0.5 : 0.3333));
        }
        if(game.primaryTarget!-1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1], modifier: (upgraded ? 0.5 : 0.3333));
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: (upgraded ? 0.5 : 0.3333))
    }
}
class Engulf: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.destruction
    override var description: String {
        "Engulf: splits damage to all other enemies for a x\(upgraded ? "1/3" : "1/4") spell power"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "engulf"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for i in 0..<game.enemies.count{
            game.addTarget(enemy: game.enemies[i], modifier: (upgraded ? 0.3333 : 0.25))
        }
    }
}
class Isolate: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.destruction
    override var description: String {
        "Isolate: hits enemies on either side instead of target for x\(upgraded ? "1" : "3/4") spell power"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "isolate"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.primaryTarget!+1<game.enemies.count){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!+1], modifier: (upgraded ? 1 : 0.75));
        }
        if(game.primaryTarget!-1>=0){ //ensure valid index
            game.addTarget(enemy:game.enemies[game.primaryTarget!-1], modifier: (upgraded ? 1 : 0.75));
        }
        game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: -game.targets[game.primaryTarget!])
    }
}
class Ricochet: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.manipulation
    override var description: String {
        "Ricochet: splits damage among \(upgraded ? 7 : 5) random targets dealing a x1/4 spell power"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "ricochet"
    }
    override func utilizeEffect(game: RuneBinderGame){
        for _ in 0..<(upgraded ? 7 : 5){
            let rand = Int.random(in: 0..<game.targets.count)
            game.addTarget(enemy: game.enemies[rand], modifier: 0.25)
        }
    }
}
class Eliminate: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.manipulation
    override var description: String {
        "Eliminate: hits the lowest health enemy ignoring target for x\(upgraded ? 2 : 1.5) spell power"
    }
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        image = "eliminate"
    }
    override func utilizeEffect(game: RuneBinderGame){
        var smallest: Enemy = game.enemies[0]
        for enemy in game.enemies{
            if(enemy.currentHealth<smallest.currentHealth){
                smallest = enemy
            }
        }
        game.changeTarget(enemy: smallest, modifier: (upgraded ? 2 : 1.5))
    }
}
class Aspire: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.manipulation
    override var description: String {
        "Aspire: hits the highest health enemy ignoring target for x\(upgraded ? 2.5 : 2) spell power"
    }
    required init() {
        super.init()
        priority = 1
        color = Color.gray
    }
    override func utilizeEffect(game: RuneBinderGame){
        var biggest: Enemy = game.enemies[0]
        for enemy in game.enemies{
            if(enemy.currentHealth>biggest.currentHealth){
                biggest = enemy
            }
        }
        game.changeTarget(enemy: biggest, modifier: (upgraded ? 2.5 : 2))
    }
}
class Randomize: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.manipulation
    override var description: String {
        "Randomize: hits a random enemy ignoring target for x\(upgraded ? 3 : 2.5) spell power"
    }
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        image = "randomize"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[Int.random(in:0..<game.enemies.count)], modifier: (upgraded ? 3 : 2.5))
    }
}
class Spray: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.manipulation
    override var description: String {
        "Spray: hits closest enemy ignoring target for x\(upgraded ? 2.5 : 2) spell power"
    }
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        image = "spray"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[0], modifier: (upgraded ? 2.5 : 2))
    }
}
class Lob: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.manipulation
    override var description: String {
        "Lob: hits furthest enemy ignoring target for x\(upgraded ? 2 : 1.5) spell power"
    }
    required init() {
        super.init()
        priority = 1
        color = Color.gray
        image = "lob"
    }
    override func utilizeEffect(game: RuneBinderGame){
        game.changeTarget(enemy: game.enemies[game.enemies.count-1], modifier: (upgraded ? 2 : 1.5))
    }
}
class Enclose: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.destruction
    override var description: String {
        "Enclose: hits for x\(upgraded ? 3 : 2) spell power if one enemy remains and x1/2 spell power otherwise"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "enclose"
    }
    override func utilizeEffect(game: RuneBinderGame){
        if(game.enemies.count>1){
            for i in 0..<game.targets.count{
                game.addTarget(enemy: game.enemies[i], modifier: -game.targets[i]/2)
            }
        }
        else{
            game.addTarget(enemy: game.enemies[game.primaryTarget!], modifier: (upgraded ? 3 : 2))
        }
    }
}
class Amplify: Enchantment{
    var rarity = rarity.legendary
    var archetype = archetype.manipulation
    override var description: String {
        "Amplify: also hits all enemies behind the target increasing spell power by x\(upgraded ? "1/2" : "1/3")"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.gray
        image = "amplify"
    }
    override func utilizeEffect(game: RuneBinderGame){
        let inc: Int = 1
        while(game.primaryTarget! + inc < game.enemies.count){
            game.addTarget(enemy: game.enemies[game.primaryTarget!+inc], modifier: (upgraded ? 0.5 : 0.33)*Double(inc))
        }
    }
}
/*
    Hex: Apply curses debuffing enemies and unique effects
 */
class VampiricStrike: Enchantment{
    var rarity = rarity.rare
    var archetype = archetype.hex
    override var description: String {
        "Vampiric Strike: heal based on damage done"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.red
    }
    override func utilizeEffect(game: RuneBinderGame){
    }
}
class SerratedStrike: Enchantment{
    var rarity = rarity.uncommon
    var archetype = archetype.hex
    override var description: String {
        "Serrated Strike: apply \(upgraded ? 4 : 3) bleed to all enemies hit"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.red
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
    var archetype = archetype.hex
    override var description: String {
        "Discombobulate: builds up stun power based on damage dealt"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.red
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
    var archetype = archetype.hex
    override var description: String {
        "Cripple: apply 1 frail to enemies hit"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.red
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
    var archetype = archetype.hex
    override var description: String {
        "Pierce: spell damage ignores enemy block"
    }
    required init() {
        super.init()
        priority = 2
        color = Color.red
    }
    override func utilizeEffect(game: RuneBinderGame){
    }
}

//
//  GameState.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/26/25.
//

import Foundation

/* This struct contains a codable format of all the information representing the game state during a run
 * to be saved as JSON file. When reopening the app and continuing the run the JSON file will be parsed
 * and all the objects will be created. To simplify data being stored and constantly loading/unloading JSON
 * the game will only be saved when and encounter is selected, combat is won, reward option is selected. If
 * you leave mid combat the game should be restored to the begginning of the combat.
 */
struct GameState: Codable {
    //var grid: [Rune]
    //var enchantQueue: [Rune]
    var gridSize: Int

    var spellLibrary: [String]          // store type names, reconstruct later
    var rewardEnchants: [String]
    var spellBook: [EnchantmentData]    // see Step 2
    var spellDeck: [EnchantmentData]
    var maxEnchants: Int

    var playerHealth: Int                // Only current health is needed rn
    var enemies: [EnemyData]            // Codable version of Enemy
    var enemyLimit: Int

    //var map: [[MapNode]]

    var victory: Bool
    var defeat: Bool
}

struct EnchantmentData: Codable {
    var id: UUID
    var enchantName: String       // "Empower"
    var upgraded: Bool
}

struct EnemyData: Codable {
    var id: UUID
    var enemyName: String       // "Goblin"
}

typealias EnchantmentFactory = () -> Enchantment

struct EnchantmentRegistry {
    private static var factories: [String: EnchantmentFactory] = [:]
    
    static func register(_ name: String, factory: @escaping EnchantmentFactory) {
        factories[name] = factory
    }
    
    static func make(from data: EnchantmentData) -> Enchantment {
        if let factory = factories[data.enchantName] {
            let enchant = factory()
            // restore serializable fields
            enchant.id = data.id
            enchant.upgraded = data.upgraded
            return enchant
        } else {
            fatalError("Unable to load enchantment: \(data.enchantName)")
        }
    }
}



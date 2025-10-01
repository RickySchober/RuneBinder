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
 * the game will only be saved when and encounter is selected, encounter ends, or you return to map. If
 * you leave mid encounter the save will regenerate the encounter at the beggining. Generation should be the
   same since it is seeded.
 */
struct GameState: Codable {
    var node: NodeType?
    var seed: [UInt64]
    //var grid: [RuneData] //currently no need to store runes as save will load start of combat and generate grid
    var gridSize: Int
    //Even though spellLibrary and rewardEnchants only care about type store full instance to avoid duplicate registries
    var spellLibrary: [EnchantmentData]
    var spellBook: [EnchantmentData]
    //var spellDeck: [EnchantmentData] //As there are no saves mid combat deck is always full so no point saving
    var maxEnchants: Int

    var playerHealth: Int                // Only current health is needed rn
    //var enemies: [EnemyData]           // As there are no saves mid combat enemies are generated when reloading
    var enemyLimit: Int

    var map: [MapNodeData]

    var encounterOver: Bool
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

struct RuneData: Codable {
    var letter: String
    var power: Int
    var id: UUID
    var enchant: EnchantmentData?
    var debuff: Debuff?
}

struct MapNodeData: Codable, Identifiable {
    var id: UUID
    var position: Int
    var layer: Int
    var icon: String
    var selectable: Bool
    var type: NodeType?
    var nextNodeIDs: [UUID]   // references by ID, not object pointers
}

extension Array where Element == [MapNode] {
    func toData() -> [MapNodeData] {
        flatMap { row in row.map { $0.toData() } }
    }
}

func rebuildMap(from datas: [MapNodeData]) -> [[MapNode]] {
    let nodesDict = MapNode.fromDataArray(datas)
    // group by layer into 2D array
    let grouped = Dictionary(grouping: nodesDict.values, by: { $0.layer })
    let maxLayer = grouped.keys.max() ?? 0
    return (0...maxLayer).map { layer in
        grouped[layer]?.sorted(by: { $0.position < $1.position }) ?? []
    }
}

func makeEnchantment(from data: EnchantmentData) -> Enchantment {
    var newEnchant: Enchantment
    switch data.enchantName {
    case "Empower": newEnchant = Empower()
    case "Enlarge": newEnchant = Enlarge()
    case "Swarm": newEnchant = Swarm()
    case "Magnify": newEnchant = Magnify()
    case "Diversify": newEnchant = Diversify()
    case "Replicate": newEnchant = Replicate()
    case "Expidite": newEnchant = Expidite()
    case "Restart": newEnchant = Restart()
    case "Foresee": newEnchant = Foresee()
    case "Rewrite": newEnchant = Rewrite()
    case "Master": newEnchant = Master()

    case "Revitalize": newEnchant = Revitalize()
    case "Ward": newEnchant = Ward()
    case "Outlast": newEnchant = Outlast()
    case "Brace": newEnchant = Brace()
    case "Deflect": newEnchant = Deflect()
    case "Fortify": newEnchant = Fortify()
    case "Nullify": newEnchant = Nullify()
    case "Purity": newEnchant = Purity()
    case "Purify": newEnchant = Purify()
    case "Ignorance": newEnchant = Ignorance()
    case "CleansingWave": newEnchant = CleansingWave()
    case "Pacifism": newEnchant = Pacifism()

    case "Extend": newEnchant = Extend()
    case "Expand": newEnchant = Expand()
    case "Engulf": newEnchant = Engulf()
    case "Isolate": newEnchant = Isolate()
    case "Gatling": newEnchant = Gatling()
    case "Eliminate": newEnchant = Eliminate()
    case "Aspire": newEnchant = Aspire()
    case "Randomize": newEnchant = Randomize()
    case "Shotgun": newEnchant = Shotgun()
    case "Lob": newEnchant = Lob()
    case "Enclose": newEnchant = Enclose()
    case "Snowball": newEnchant = Snowball()

    case "VampiricStrike": newEnchant = VampiricStrike()
    case "SerratedStrike": newEnchant = SerratedStrike()
    case "Discombobulate": newEnchant = Discombobulate()
    case "Cripple": newEnchant = Cripple()
    case "Pierce": newEnchant = Pierce()

    default:
        fatalError("Unknown enchantment type: \(data.enchantName)")
    }
    newEnchant.id = data.id
    newEnchant.upgraded = data.upgraded
    return newEnchant
}
func makeEnemy(from data: EnemyData) -> Enemy {
    var newEnemy: Enemy
    switch data.enemyName {
    case "Goblin": newEnemy = Goblin()
    case "MultiplyingMycospawn": newEnemy = MultiplyingMycospawn()
    default:
        fatalError("Unknown enchantment type: \(data.enemyName)")
    }
    newEnemy.id = data.id
    return newEnemy
}



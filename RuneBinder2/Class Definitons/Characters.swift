//
//  Characters.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/15/25.
//

import Foundation

struct Characters: Codable, Equatable, Identifiable{
    
    static func == (lhs: Characters, rhs: Characters) -> Bool {
        return lhs.id == rhs.id
    }
    
    let startingDeck: [EnchantmentData]
    let affinities: [Enchantment.archetype]
    let id: String
}

let hermit: Characters = Characters(
    startingDeck: [Empower().toData(),Empower().toData(),Empower().toData(),Ward().toData(),Ward().toData(),Ward().toData(),Enlarge().toData(),Brace().toData()],
    affinities: [.destruction, .preservation],
    id: "Hermit")

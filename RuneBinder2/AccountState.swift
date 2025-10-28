//
//  AccountState.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/14/25.
//

import Foundation
struct PlayerAccount: Codable {
    var gold: Int
    var unlockedCharacters: [Characters]
    var unlockedRunes: [String]
    var achievements: [String]
    var settings: GameSettings
    var totalRuns: Int
    var bestScore: Int
}

struct GameSettings: Codable {
    var soundEnabled: Bool
    var musicVolume: Double
}

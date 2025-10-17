//
//  AccountViewModel.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/14/25.
//

import Foundation
final class AccountManager: ObservableObject {
    @Published var account: PlayerAccount
    
    private let saveURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        saveURL = documents.appendingPathComponent("PlayerAccount.json")

        if let data = try? Data(contentsOf: saveURL),
           let decoded = try? JSONDecoder().decode(PlayerAccount.self, from: data) {
            account = decoded
        } else { //If no data found create default
            account = PlayerAccount(
                gold: 0,
                unlockedCharacters: [hermit],
                unlockedRunes: [],
                achievements: [],
                settings: GameSettings(soundEnabled: true, musicVolume: 0.8),
                totalRuns: 0,
                bestScore: 0
            )
            save()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(account)
            try data.write(to: saveURL)
        } catch {
            print("❌ Failed to save account data:", error)
        }
    }
}

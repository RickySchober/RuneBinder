import Foundation

struct EnemyEncounter {
    let enemyFactories: [(Int) -> Enemy]
    let difficulty: Int
    let zone: Zone

    enum Zone: String, Codable {
        case Forest
        case Citadel
    }

    func generateEnemies() -> [Enemy] {
        enemyFactories.enumerated().map { $1($0) }
    }
}

struct EnemyEncounterData: Codable {
    struct EnemyData: Codable {
        let type: String
        let position: Int
    }

    let enemies: [EnemyData]
    let difficulty: Int
    let zone: String
}

let enemyFactory: [String: (Int) -> Enemy] = [
    "PoisonShroom": { PoisonShroom(pos: $0) },
    "Goblin": { Goblin(pos: $0) },
    "RabidWolf": { RabidWolf(pos: $0) },
    "TorchBearer": { TorchBearer(pos: $0) },
    "Tree": { Tree(pos: $0) }
]

class EncounterPool {
    static let shared = EncounterPool()
    var encounters: [EnemyEncounter] = []

    init() {
        loadEncounters()
    }

    private func loadEncounters() {
        guard let url = Bundle.main.url(forResource: "ForestEncounters", withExtension: "json") else {
            print("Failed to locate encounters.json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([EnemyEncounterData].self, from: data)
            self.encounters = decoded.compactMap { data in
                guard let zone = EnemyEncounter.Zone(rawValue: data.zone) else { return nil }

                let factories: [(Int) -> Enemy] = data.enemies.compactMap { enemy in
                    enemyFactory[enemy.type]
                }

                return EnemyEncounter(enemyFactories: factories, difficulty: data.difficulty, zone: zone)
            }
        } catch {
            print("Error loading encounters: \(error)")
        }
    }
    func getEncounters(forZone zone: EnemyEncounter.Zone, difficulty level: Int) -> [EnemyEncounter] {
        return encounters.filter { $0.zone == zone && $0.difficulty == level }
    }

    func getRandomEncounter(forZone zone: EnemyEncounter.Zone, difficulty level: Int) -> EnemyEncounter? {
        return getEncounters(forZone: zone, difficulty: level).randomElement()
    }
}

import Foundation

struct EnemyEncounter {
    let enemies: [Enemy]
    let difficulty: Int
    enum Zone{
        case Forest
        case Citadel
    }
    let zone: Zone
}

class EncounterPool {
    static let shared = EncounterPool()
    
    let encounters: [EnemyEncounter] = [
        EnemyEncounter(enemies: [PoisonShroom(pos: 0)], difficulty: 1, zone: .Forest),
        EnemyEncounter(enemies: [Goblin(pos: 0), Goblin(pos: 1)], difficulty: 1, zone: .Forest),
        EnemyEncounter(enemies: [RabidWolf(pos: 0), Goblin(pos: 1)], difficulty: 1, zone: .Forest),
        EnemyEncounter(enemies: [TorchBearer(pos: 0)], difficulty: 1, zone: .Forest),

        EnemyEncounter(enemies: [PoisonShroom(pos: 0), PoisonShroom(pos: 1)], difficulty: 2, zone: .Forest),
        EnemyEncounter(enemies: [TorchBearer(pos: 0), Goblin(pos: 1)], difficulty: 2, zone: .Forest),
        EnemyEncounter(enemies: [RabidWolf(pos: 0), RabidWolf(pos: 1), Goblin(pos: 2)], difficulty: 2, zone: .Forest),
        EnemyEncounter(enemies: [Tree(pos: 0)], difficulty: 2, zone: .Forest)
    ]
    
    func getEncounters(forZone zone: EnemyEncounter.Zone, difficulty level: Int) -> [EnemyEncounter] {
        return encounters.filter { $0.zone == zone && $0.difficulty == level }
    }

    func getRandomEncounter(forZone zone: EnemyEncounter.Zone, difficulty level: Int) -> EnemyEncounter? {
        return getEncounters(forZone: zone, difficulty: level).randomElement()
    }
}


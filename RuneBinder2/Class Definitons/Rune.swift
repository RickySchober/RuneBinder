//
//  Rune.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//
//Runes have a location on the grid but may also be used for spelling
//there position in the word is represented by an integer if this int is -1 not in word
import Foundation

struct Debuff: Codable{
    enum Archetype: String, Codable{
        case lock, scorch, weak, rot
    }
    let archetype: Archetype
    var value: Int
    var image: String {
            switch archetype {
            case .lock: return "lock"
            case .rot: return "rot"
            case .weak: return "weak"
            case .scorch: return "scorch"
            }
        }

    var text: String {
        switch archetype {
        case .lock:
            return "Locked: Cannot be used in spell for \(value) turns"
        case .rot:
            return "Rot: unused rune deals you \(value) damage at turns end increasing by 1 every round"
        case .weak:
            return "Weaken: has no spell power for \(value) turns"
        case .scorch:
            return "Scorch: unused rune is destroyed at turns end and deals you \(value) damage"
        }
    }
    init(archetype: Archetype, value: Int) {
        self.archetype = archetype
        self.value = value
    }
}
class Rune: Identifiable, Equatable{
    var letter: String
    var power: Int
    let id: UUID
    var enchant: Enchantment?
    var debuff: Debuff?
    init(l: String, p: Int, e: Enchantment?){
        letter = l
        power = p
        id = UUID()
        enchant = e
    }
    init(data: RuneData){
        letter = data.letter
        power = data.power
        id = data.id
        enchant = (data.enchant != nil) ? makeEnchantment(from: data.enchant!) : nil
        debuff = data.debuff
    }
    static func ==(lhs: Rune, rhs: Rune) -> Bool {
        return lhs.id == rhs.id
    }
}
extension Rune { //Converts class into codable struct for storage
    func toData() -> RuneData {
        RuneData(
            letter: letter,
            power: power,
            id: id,
            enchant: (enchant != nil) ? enchant!.toData() : nil,
            debuff: debuff
        )
    }
}

//
//  Rune.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//
//Runes have a location on the grid but may also be used for spelling
//there position in the word is represented by an integer if this int is -1 not in word
import Foundation

struct Debuff{
    enum type{
        case lock
        case scorch
        case weak
        case rot
    }
    let type: type
    var value: Int
    let image: String
    let text: String
    init(type: type, value: Int) {
        self.type = type
        self.value = value
        if(self.type == .lock){
            image = "chain"
            text = "🔒 Locked: Cannot be used in spell for \(self.value) turns"
        }
        else if(self.type == .rot){
            image = "rot"
            text = "💀 Rot: unused rune deals you \(self.value) damage at turns end increasing by 1 every round"
        }
        else if(self.type == .weak){
            image = "weak"
            text = "🌀 Weaken: has no spell power for \(self.value) turns"
        }
        else{
            image = "fire"
            text = "🔥 Scorch: unused rune is destroyed at turns end and deals you \(self.value) damage"
        }
    }
}
class Rune: Identifiable, Equatable{
    var letter: Character
    var power: Int
    let id: UUID
    var enchant: Enchantment?
    var debuff: Debuff?
    init(l: Character, p: Int, e: Enchantment?){
        letter = l
        power = p
        id = UUID()
        enchant = e
    }
    static func ==(lhs: Rune, rhs: Rune) -> Bool {
        return lhs.id == rhs.id
    }
}


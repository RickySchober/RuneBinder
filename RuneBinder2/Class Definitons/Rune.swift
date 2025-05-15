//
//  Rune.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//
//Runes have a location on the grid but may also be used for spelling
//there position in the word is represented by an integer if this int is -1 not in word

import Foundation
class Rune: Identifiable, Equatable{
    var letter: Character
    var power: Int
    let id: UUID
    var enchant: Enchantment?
    var lock: Bool = false
    var scorch: Bool = false
    var weaken: Bool = false
    var rot: Bool = false
    
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


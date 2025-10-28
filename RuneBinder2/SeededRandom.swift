//
//  SeededRandom.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/26/25.
//

import Foundation

/* In order to prevent changes to random events such as reward generation, encounter generation, and
 * deck shuffling when quiting and loading mid run a seedstate will give consistensy to random event.
 * As these events should be independent (shuffling the deck more should not change reward generation)
 * the seed will be broken up into sections of 4 digits for reward generation, encounter generation, and
 * deck shuffling. An example full seed will look like 4782 5927 1293
 */
/*
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}*/

struct SeededGenerator: RandomNumberGenerator, Codable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }

    // Get a number in range
    mutating func nextInt(in range: Range<Int>) -> Int {
        Int(next() % UInt64(range.count)) + range.lowerBound
    }

    // Save/load current state
    func saveState() -> UInt64 { state }
    mutating func loadState(_ saved: UInt64) { state = saved }
}

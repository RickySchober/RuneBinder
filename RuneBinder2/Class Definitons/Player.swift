//
//  Player.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/23.
//

import Foundation

struct Player{
    var currentHealth: Int
    var maxHealth: Int
    var block: Int = 0
    var outlast: Int = 0
    var deflect: Int = 0
    var nullify: Int = 0
    init(currentHealth: Int, maxHealth: Int) {
        self.currentHealth = currentHealth
        self.maxHealth = maxHealth
    }
    //mutating func cleanUp() {
        
    //}
    mutating func startUp() {
        if(outlast>0){
            outlast -= 1
        }
        else{
            block = 0;
        }
    }
}

//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import SwiftUI
class RuneBinderViewModel: ObservableObject {
    @Published private var model: RuneBinderGame = RuneBinderGame()
    
    var grid: Array<Rune>{
        model.grid
    }
    var spell: Array<Rune>{
        model.spell
    }
    var validSpell: Bool{
        model.validSpell
    }
    var spellPower: Int{
        model.getSpellPower()
    }
    var player: Player{
        model.player
    }
    var target: Enemy?{
        model.primaryTarget
    }
    var enemies: Array<Enemy>{
        model.enemies
    }
    var spellRuneSize: Double{
        model.spellRuneSize()
    }
    func selectRune(rune: Rune){
        model.selectRune(rune: rune)
        model.checkSpellValid()
        objectWillChange.send()
    }
    func castSpell(){
        model.castSpell()
        model.checkSpellValid()
        model.enemyTurn()
        objectWillChange.send()
    }
    func selectEnemy(enemy: Enemy){
        model.changeTarget(enemy: enemy)
        objectWillChange.send()
    }
}

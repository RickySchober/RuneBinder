//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import SwiftUI
class RuneBinderViewModel: ObservableObject {
    @Published private var model: RuneBinderGame = createRuneBinderGame()
    
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
    var enemies: Array<Enemy>{
        model.targets
    }
    var spellRuneSize: Double{
        model.spellRuneSize()
    }
    func selectRune(rune: Rune){
        model.selectRune(rune: rune)
        model.checkSpellValid()
    }
    func castSpell(){
        model.castSpell()
        model.checkSpellValid()
    }
    func selectEnemy(enemy: Enemy){
        model.changeTarget(enemy: enemy)
    }
    
    func startNewArmyGame(resourceAbundance: Int, enemyLevel: Int){
        model = RuneBinderViewModel.createRuneBinderGame()
    }
    private static func createRuneBinderGame() -> RuneBinderGame {  
        return RuneBinderGame()
    }
}

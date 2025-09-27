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
        model.spellPower
    }
    var player: Player{
        model.player
    }
    var target: Enemy?{
        if(model.primaryTarget==nil){
            return nil
        }
        return model.enemies[model.primaryTarget!]
    }
    var targets: [Enemy]{ //Returns enemies that will be hit for purpose of highlighting
        var temp: [Enemy] = []
        for i in 0..<model.targets.count{
            if(model.targets[i]>0.0){ //If enemy is being hit
                temp.append(model.enemies[1])
            }
        }
        return temp
    }
    var enemies: Array<Enemy>{
        model.enemies
    }
    var spellRuneSize: Double{
        model.spellRuneSize()
    }
    var rewardEnchants: [Enchantment.Type]{
        model.rewardEnchants
    }
    var map: [[MapNode]]{
        model.map
    }
    var victory: Bool{
        model.victory
    }
    var selectedRune: Rune?{
        model.selectedRune
    }
    var spellDeck: [Enchantment]{
        model.spellDeck
    }
    func hoverRune(rune: Rune?){
        model.hoverRune(rune: rune)
        objectWillChange.send()
    }
    func selectRune(rune: Rune){
        model.selectRune(rune: rune)
        model.checkSpellValid()
        objectWillChange.send()
    }
    func playerTurnEnd(){
        model.runeDebuffs()
        model.enemyTurn()
        model.cleanUp()
        objectWillChange.send()

    }
    func castSpell(){
        model.castSpell()
        model.checkSpellValid()
        playerTurnEnd()
    }
    func selectEnemy(enemy: Enemy){
        model.changeTarget(enemy: enemy, modifier: 1.0)
        objectWillChange.send()
    }
    func selectNode(node: MapNode){
        model.selectNode(node: node)
        objectWillChange.send()
    }
    func selectReward(enchant: Enchantment.Type){
        model.addEnchant(enchant: enchant)
        objectWillChange.send()
    }
    func shuffleGrid(){
        model.shuffleGrid()
        playerTurnEnd()
    }
}

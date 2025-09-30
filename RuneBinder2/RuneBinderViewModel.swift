//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import SwiftUI
class RuneBinderViewModel: ObservableObject {
    @Published private var model: RuneBinderGame    
    private let persistence = SaveManager()
    private var gameState: GameState?
    
    init(){
        gameState = nil
        model = RuneBinderGame()
    }
    //Loads in previous game state from json and create model object with initial values from game state
    func loadSave(){
        gameState = persistence.load()
        model = (gameState != nil) ? RuneBinderGame(state: gameState!) : RuneBinderGame()
    }
    func saveGame(){
        gameState = GameState(
            gridSize: model.gridSize,
            spellLibrary: model.spellLibrary.map { $0.init().toData() },
            rewardEnchants: rewardEnchants.map { $0.init().toData() },
            spellBook: model.spellBook.map { $0.toData() },
            spellDeck: model.spellDeck.map { $0.toData() },
            maxEnchants: model.maxEnchants,
            playerHealth: model.player.currentHealth,
            enemies: model.enemies.map { $0.toData() },
            enemyLimit: model.enemyLimit,
            map: model.map.toData(),
            victory: model.victory,
            defeat: model.defeat
        )
        persistence.save(state: gameState!)
    }
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
        saveGame()
        objectWillChange.send()
    }
    func selectReward(enchant: Enchantment.Type){
        model.addEnchant(enchant: enchant)
        saveGame()
        objectWillChange.send()
    }
    func shuffleGrid(){
        model.shuffleGrid()
        playerTurnEnd()
    }
}

class SaveManager {
    private var saveURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("runebinder.json")
    }

    func save(state: GameState) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: saveURL)
            print("✅ Game saved")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }

    func load() -> GameState? {
        do {
            let data = try Data(contentsOf: saveURL)
            let state = try JSONDecoder().decode(GameState.self, from: data)
            print("✅ Game loaded")
            return state
        } catch {
            print("❌ Failed to load: \(error)")
            return nil
        }
    }
}

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
    @Published var floatingTexts: [FloatingTextData] = []
    struct FloatingTextData: Identifiable, Equatable {
        let id = UUID()
        let enemyId: UUID
        let text: String
        let color: Color
    }
    init(){
        gameState = nil
        model = RuneBinderGame()
    }
    //Loads in previous game state from json and create model object with initial values from game state
    func loadSave() -> GameScreen{
        gameState = persistence.load()
        model = (gameState != nil) ? RuneBinderGame(state: gameState!) : RuneBinderGame()
        switch gameState?.node{
        case nil: return GameScreen.map
        case .combat: return GameScreen.combat
        case .elite: return GameScreen.combat
        case .event: return GameScreen.event
        case .rest: return GameScreen.rest
        case .shop: return GameScreen.shop
        }
    }
    func saveGame(node: NodeType?){
        gameState = GameState(
            node: node, //Viewmodel determines appropriate screen to restore to based on model state
            seed: [model.encounterRng.saveState(), model.rewardRng.saveState(), model.shufflingRng.saveState()],
            gridSize: model.gridSize,
            spellLibrary: model.spellLibrary.map { $0.init().toData() },
            spellBook: model.spellBook.map { $0.toData() },
            maxEnchants: model.maxEnchants,
            playerHealth: model.player.currentHealth,
            enemyLimit: model.enemyLimit,
            map: model.map.toData(),
            encounterOver: model.encounterOver,
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
    var encounterOver: Bool{
        model.encounterOver
    }
    var selectedRune: Rune?{
        model.selectedRune
    }
    var spellDeck: [Enchantment]{
        model.spellDeck
    }
    var spellBook: [Enchantment]{
        model.spellBook
    }
    func hoverRune(rune: Rune?){
        model.hoverRune(rune: rune)
        objectWillChange.send()
    }
    func selectCharacter(character: Characters){
        model.selectCharacter(character: character)
    }
    func selectRune(rune: Rune){
        model.selectRune(rune: rune)
        model.checkSpellValid()
        objectWillChange.send()
    }
    func playerTurnEnd(){
        model.runeDebuffs()
        model.enemyTurn()
        if(model.cleanUp()){ //Combat is over
            saveGame(node: NodeType.combat)
            model.generateEnchantRewards()
        }
        objectWillChange.send()

    }
    func castSpell(){
        model.castSpell()
        Task {
            await playCombatEvents(from: model) // visual playback
        }
        model.checkSpellValid()
        playerTurnEnd()
    }
    @MainActor
    func playCombatEvents(from model: RuneBinderGame) async {
        for event in model.eventLog {
            Task{
                await show(event)
            }
            try? await Task.sleep(for: .seconds(0.3))
        }
        model.eventLog.removeAll()
    }
    @MainActor
    func show(_ event: CombatEvent) async {
        switch event {
       /* case .runeActivated(let rune):
            currentFloatingText = "Activating \(rune.enchant?.description ?? "")"
            SoundManager.shared.playSoundEffect(named: "rune_cast")*/
        case .damage(let enemyIndex, let amount):
            let enemy = enemies[enemyIndex]
            SoundManager.shared.playSoundEffect(named: enemy.hitSound)
            await showFloatingText("\(amount)", color: .red, over: enemy)
            
        case .death(let enemyIndex):
            SoundManager.shared.playSoundEffect(named: enemies[enemyIndex].deathSound)
            await showFloatingText("💀", color: .gray, over: enemies[enemyIndex])

        case .sound(let name):
            SoundManager.shared.playSoundEffect(named: name)
        case .runeActivated(_):
            print("gogogogolem")
        }
    }
    @MainActor
    func showFloatingText(_ text: String, color: Color, over enemy: Enemy) async {
        let newText = FloatingTextData(
            enemyId: enemy.id,
            text: text,
            color: color
        )
        // Add this floating text
        floatingTexts.append(newText)
        
        // Wait for animation duration
        try? await Task.sleep(for: .seconds(0.6))
        
        // Remove it after the animation completes
        if let index = floatingTexts.firstIndex(of: newText) {
            floatingTexts.remove(at: index)
        }
    }
    func selectEnemy(enemy: Enemy){
        model.changeTarget(enemy: enemy, modifier: 1.0)
        objectWillChange.send()
    }
    func selectNode(node: MapNode){
        model.selectNode(node: node)
        saveGame(node: node.type)
        model.loadNode(node: node.type!)
        objectWillChange.send()
    }
    func selectReward(enchant: Enchantment.Type){
        model.addEnchant(enchant: enchant)
        objectWillChange.send()
    }
    func returnToMap(){
        saveGame(node: nil)
    }
    func shuffleGrid(){
        model.shuffleGrid()
        playerTurnEnd()
    }
    //Rest Area options
    func rest(){
        model.changeHealth(num: player.maxHealth/3)
        model.encounterOver = true
        saveGame(node: .rest)
        objectWillChange.send()
    }
    func upgradeEnchant(enchant: Enchantment){
        enchant.upgraded = true
        model.encounterOver = true
        saveGame(node: .rest)
        objectWillChange.send()
    }
    func removeEnchant(enchant: Enchantment){
        model.removeEnchantment(enchant: enchant)
        model.encounterOver = true
        saveGame(node: .rest)
        objectWillChange.send()
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

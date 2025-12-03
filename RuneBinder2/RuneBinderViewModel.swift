//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import SwiftUI

struct FloatingTextData: Identifiable, Equatable {
    let id = UUID()
    let entityId: UUID
    let text: String
    let color: Color
}

class RuneBinderViewModel: ObservableObject {
    @Published private var model: RuneBinderGame    
    private let persistence = SaveManager()
    private var gameState: GameState?
    //Animation tracking vars
    @Published var floatingTexts: [FloatingTextData] = []
    @Published var isAnimatingTurn: Bool = false
    @Published var lunge: UUID = UUID()
    @Published var lungeTrigger = false
    @Published var action: UUID = UUID()
    @Published var actionTrigger = false

    
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
            temp.append(model.targets[i].enemy)
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
    var hoveredRune: Rune?{
        model.hoveredRune
    }
    var hoveredEntity: Entity?{
        model.hoveredEntity
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
    func hoverEntity(entity: Entity?){
        model.hoverEntity(entity: entity)
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
    func playerTurnStart(){
        isAnimatingTurn = false
        player.triggerBuffs()
        for enemy in enemies {
            enemy.chooseAction(game: model)
        }
        model.player.actions = 2 //reset actions
    }
    func playerTurnEnd(){
        player.triggerDebuffs().forEach { model.addAnimation(event: $0) }
        model.runeDebuffs()
        if(model.cleanUp()){ //Combat is over
            saveGame(node: NodeType.combat)
            model.generateEnchantRewards()
        }
        else{
            Task{
                await enemyTurns()
            }
        }
        objectWillChange.send()
    }
    @MainActor
    func enemyTurnEnd(){
        Task{
            for enemy in enemies {
                enemy.triggerDebuffs().forEach { model.addAnimation(event: $0) }
                await playCombatEvents(from: model)
            }
            if(model.cleanUp()){ //Combat is over
                saveGame(node: NodeType.combat)
                model.generateEnchantRewards()
            }
            playerTurnStart()
            objectWillChange.send()
        }
    }
    @MainActor
    func castSpell(){
        Task{
            if(model.prepareSpell()){ //returns true when ready to cast
                isAnimatingTurn = true
                for rune in model.enchantQueue{
                    if(rune.enchant!.priority>=3 && model.targets.isEmpty){ //If spell contains no additional targets add base hit
                        model.addTarget(hit: Hit(enemy: enemies[model.primaryTarget!], modifier: model.primaryModifer))
                    }
                    rune.enchant?.utilizeEffect(game: model)
                    if(rune.enchant?.priority==0){
                        print("i am waiting")
                        await playCombatEvents(from: model)
                    }
                }
                if(model.targets.isEmpty){ //If spell contains no additional targets add base hit
                    model.addTarget(hit: Hit(enemy: enemies[model.primaryTarget!], modifier: model.primaryModifer))
                }
                model.addAnimation(event: .lunge(id: player.id, delay: 0.5))
                for i in model.targets.indices {
                    model.resolveHit(hit: model.targets[i])
                    await playCombatEvents(from: model)
                }
                model.spellCleanup()
                model.player.actions -= 1
                if(player.actions<=0){
                    playerTurnEnd()
                }
                else{
                    if(model.cleanUp()){ //Combat is over
                        saveGame(node: NodeType.combat)
                        model.generateEnchantRewards()
                    }
                    isAnimatingTurn = false
                }
            }
        }
    }
    /* Go through all the enemy turns using their actions. For each action resolve each part of the effect
       in order: unique effects, damage, ward, debuffs, runedebuffs.
     */
    @MainActor
    func enemyTurns(){
        for enemy in enemies {
            enemy.triggerBuffs()
        }
        Task{
            for enemy in enemies {
                if(enemy.chosenAction != nil){
                    let action: Action = enemy.chosenAction!
                    action.utilizeEffect(game: model) // Any special effects related to action
                    await playCombatEvents(from: model)

                    model.addAnimation(event: .action(id: enemy.id, delay: 1.0))
                    await playCombatEvents(from: model)
                    
                    if(action.damage > 0){ //Hit portion of action
                        model.addAnimation(event: .lunge(id: enemy.id, delay: 0.5))
                        await playCombatEvents(from: model)
                        let damage: Int = model.player.takeDamage(hit: action.damage)
                        model.addAnimation(event: .damage(id: player.id, amount: damage, delay: 0.5))
                        await playCombatEvents(from: model)
                    }
                    if(action.gaurd > 0){
                        enemy.ward += action.gaurd
                        model.addAnimation(event: .implicit(delay: 0.5))
                        await playCombatEvents(from: model)
                    }
                    for debuff in action.debuffs{
                        player.applyDebuff(debuff: debuff)
                        model.addAnimation(event: .implicit(delay: 0.5))
                        await playCombatEvents(from: model)
                    }
                    if(player.buffs.contains { $0.archetype == .nullify}) { //Negates debuffs from an attack
                        return
                    }
                    var debuffable: Int = 0
                    for rune in grid{
                        if(rune.debuff == nil){
                            debuffable += 1
                        }
                    }
                    for i in 0..<action.runeDebuffs.count{
                        var rand = model.shufflingRng.nextInt(in: 0..<debuffable) //assign the randth valid rune to be debuffed
                        for rune in grid{
                            if(rune.debuff == nil && rand > 0){
                                rand -= 1
                            }
                            if(rand == 0){
                                rune.debuff = action.runeDebuffs[i]
                                debuffable -= 1
                                model.addAnimation(event: .implicit(delay: 0.5))
                                await playCombatEvents(from: model)
                                break
                            }
                        }
                    }
                    enemy.chosenAction = nil
                }
            }
            enemyTurnEnd()
        }
    }
    /* On spell cast the game should play out a sequence of animations as effects resolve.
     * This includes enchantment effects as the go through the queue. Resolving all effects first
     * and then storing animations in a queue leads to complications of storing extra information.
     * Instead trigger animations to resolve asyncronously while adding blocking delay on main thread.
     * Normally blocking main thread is taboo but no valid input can be taken from user until all effects are resolved.
     * Priority 0 and 4 resolve immediately, Priority 1-3 will modify a hits
     */
    @MainActor
    func playCombatEvents(from model: RuneBinderGame) async{
        for event in model.eventLog {
            var animationDelay: Double = 0.0
                switch event {
                case .damage(let id, let amount, let delay):
                    SoundManager.shared.playSoundEffect(named: "sword_stab")
                    //SoundManager.shared.playSoundEffect(named: enemy.hitSound)
                    print("playing sound")
                    Task{
                        await showFloatingText("\(amount)", color: .red, over: id)
                    }
                    animationDelay = delay
                case .death(let enemyIndex, let delay):
                    SoundManager.shared.playSoundEffect(named: enemies[enemyIndex].deathSound)
                    Task{
                        await showFloatingText("💀", color: .gray, over: enemies[enemyIndex].id)
                    }
                    animationDelay = delay
                case .sound(let name, let delay):
                    SoundManager.shared.playSoundEffect(named: name)
                    animationDelay = delay
                case .runeActivated(let rune, let text, let delay):
                    Task{
                        await showFloatingText(text, color: rune.enchant?.color ?? .green, over: rune.id)
                    }
                    animationDelay = delay
                    print("gentlemen we got em")
                case .lunge(let id, let delay):
                    lunge = id
                    lungeTrigger.toggle()
                    animationDelay = delay
                case .action(let id, let delay):
                    action = id
                    actionTrigger.toggle()
                    animationDelay = delay
                case .debuff(let id, let debuff, let delay):
                    print("")
                case .implicit(let delay):
                    animationDelay = delay
                }
            try? await Task.sleep(for: .seconds(animationDelay))
        }
        model.eventLog.removeAll()
        print("Empty event log\(model.eventLog)")
    }
    @MainActor
    func showFloatingText(_ text: String, color: Color, over entity: UUID) async {
        let newText = FloatingTextData(
            entityId: entity,
            text: text,
            color: color
        )
        // Add this floating text
        floatingTexts.append(newText)
        
        // Wait for animation duration
        try? await Task.sleep(for: .seconds(2.0))
        
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
        isAnimatingTurn = true
        model.shuffleGrid()
        model.player.actions -= 1
        if(player.actions<=0){
            playerTurnEnd()
        }
        else{
            if(model.cleanUp()){ //Combat is over
                saveGame(node: NodeType.combat)
                model.generateEnchantRewards()
            }
            isAnimatingTurn = false
        }
        objectWillChange.send()
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

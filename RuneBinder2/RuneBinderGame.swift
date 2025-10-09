//
//  RuneBinderGame.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import Foundation
import UIKit
import SwiftUI

class RuneBinderGame: ObservableObject{
    //Seed
    private (set) var encounterRng: SeededGenerator
    private (set) var rewardRng: SeededGenerator
    private (set) var shufflingRng: SeededGenerator
    private (set) var seed: [UInt64]
    //Spell data
    private (set) var grid: Array<Rune> = []
    private (set) var enchantQueue: Array<Rune> = []
    private (set) var gridSize: Int = 16
    private (set) var spell: Array<Rune> = []
    private (set) var spellPower: Int = 0
    private (set) var damageMultiplier: Double = 0.0
    private (set) var validSpell: Bool = false
    private (set) var selectedRune: Rune? = nil
    
    private (set) var spellLibrary: Array<Enchantment.Type> //List of possible enchants to encounter during run
    private (set) var rewardEnchants: Array<Enchantment.Type> = [] //List of known enchantments
    private (set) var spellBook: [Enchantment] = [Lob(), Engulf(), Enlarge(), Ricochet(), Spray(), Aspire(), Eliminate(), Fortify(), Swarm()]//List of aquired enchants
    private (set) var spellDeck: [Enchantment]//List of undrawn enchants
    private (set) var maxEnchants: Int = 5
    private var combatCount: Int = 0

    
    var player: Player = Player(currentHealth: 50, maxHealth: 80)
    //Enemy data
    private (set) var enemies: [Enemy] = [] //Array containing the enemies in the current encounter will be in index 0-3 based on position
    private (set) var primaryTarget: Int? = nil //Each spell cast requires selecting an enemy as a target
    private (set) var primaryModifer: Double = 0.0 //The damage modifier to the primary target before additional targets
    private (set) var targets: [Double] = [0.0, 0.0, 0.0, 0.0] //Runes that modify targeting deal a portion of damage to other enemies
    private (set) var enemyLimit: Int = 4 //Maximum number of enemies in a given encounter
    //Map
    private (set) var map: [[MapNode]] = [[]]
    
    @Published var encounterOver: Bool = false
    private (set) var defeat: Bool = false

    //Array represents the relative occurence of letters in words in the dictionary
    //numbers represent the % of its occurence and correlate with A-Z
    private let letterOccurence: Array<Double> = [7.8, 2.0, 4.0, 3.8, 11, 1.4, 3.0, 2.3, 8.6, 0.21, 0.97, 5.3, 2.7, 7.2,
                                                  6.1, 2.8, 0.19, 7.3, 8.7, 6.7, 3.3, 1.0, 0.91, 0.27, 1.6, 0.44]
    init(){
        seed = [UInt64.random(in: 0...9999), UInt64.random(in: 0...9999), UInt64.random(in: 0...9999)] //random seed
        encounterRng = SeededGenerator(seed: seed[0])
        rewardRng = SeededGenerator(seed: seed[1])
        shufflingRng = SeededGenerator(seed: seed[2])
        spellLibrary = [
        Empower.self, Revitalize.self, Ward.self, CleansingWave.self, SerratedStrike.self, Purify.self,
        Spray.self, Lob.self, Swarm.self, Spray.self, Magnify.self, Enlarge.self
        ]
        spellDeck = spellBook
        map = generateMap(numLayers: 10, minNodes: 3, maxNodes: 5)
        shuffleGrid()
    }
    init(state: GameState){ //Create model from saved game state
        seed = state.seed
        encounterRng = SeededGenerator(seed: seed[0])
        rewardRng = SeededGenerator(seed: seed[1])
        shufflingRng = SeededGenerator(seed: seed[2])
        
        spellLibrary = state.spellLibrary.map { type(of: makeEnchantment(from: $0)) }
        spellBook = state.spellBook.map { makeEnchantment(from: $0) }
        maxEnchants = state.maxEnchants

        player.currentHealth = state.playerHealth           // Only current health is needed rn
        enemyLimit = state.enemyLimit

        map = rebuildMap(from: state.map)

        gridSize = state.gridSize
        encounterOver = state.encounterOver
        defeat = state.defeat
        
        spellDeck = spellBook
        if(state.node != nil){ //If you are currently on a node load it otherwise on map so do nothing
            loadNode(node: state.node!)
        }
    }
    func addEnemies(newEnemies: [Enemy], pos: Int){
        enemies.insert(contentsOf: newEnemies[..<min(newEnemies.count, enemyLimit-enemies.count)], at: pos)
    }
    func changeHealth(num:Int){
        if(player.currentHealth+num>player.maxHealth){ player.currentHealth = player.maxHealth }
        else{ player.currentHealth += num }
    }
    func changeSpellPower(num:Int){
        spellPower += num
    }
    func hoverRune(rune: Rune?){
        selectedRune = rune
    }
    //Modifies damage to additional targets based on damage to main target
    func addTarget(enemy: Enemy, modifier: Double){
        targets[enemies.firstIndex(of: enemy)!] += modifier
    }
    //Changes the primary target
    func changeTarget(enemy: Enemy, modifier: Double){
        if(primaryTarget != nil && primaryTarget == enemies.firstIndex(of: enemy)){
            primaryModifer *= modifier //If new target is same as primary target just change damage modifier
        }
        else{
            primaryTarget = enemies.firstIndex(of: enemy);
            targets = [Double](repeating: 0.0, count: enemies.count) //When new target selected reset all damage modifiers
            primaryModifer = modifier
        }
    }
    func removeEnchantment(enchant: Enchantment){
        for i in 0..<spellBook.count{
            if(enchant == spellBook[i]){
                spellBook.remove(at: i)
                return 
            }
        }
    }
    
    func generateMap(numLayers: Int, minNodes: Int, maxNodes: Int) -> [[MapNode]] {
        var map: [[MapNode]] = []
        while map.count < numLayers{
            map.append([])
        }
        for layer in 0..<numLayers {
            var nodeCount = encounterRng.nextInt(in: minNodes..<maxNodes+1)
            while(layer >= 2  && nodeCount == map[layer-1].count && nodeCount == map[layer-2].count){ //Prevent many same size in a row
                nodeCount = encounterRng.nextInt(in: minNodes..<maxNodes+1)
            }
            for i in 0..<nodeCount{
                map[layer].append(MapNode(pos: i, lay: layer, tp: .combat))
                if(layer==0){
                    map[layer][i].selectable = true
                }
            }
            
        }
        //Adds connections between layers of node depending on relative size of this layer and next layer
        for layer in 0..<(numLayers - 1) {
            if(map[layer+1].count > map[layer].count){ //Next row bigger
                let extraPaths = map[layer+1].count - map[layer].count //Randomly assign extra paths to nodes default path
                for _ in 0..<extraPaths{
                    var randPos = encounterRng.nextInt(in: 0..<map[layer].count)
                    while(!map[layer][randPos].nextNodes.isEmpty){ //Random unchosen starting node
                        randPos = encounterRng.nextInt(in: 0..<map[layer].count)
                    }
                    map[layer][randPos].nextNodes = [map[layer+1][map[layer][randPos].position*(map[layer+1].count-1)/(map[layer].count-1)]]
                }
                for i in 0..<map[layer].count {
                    let defPos = map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)] //Default next node
                    if(map[layer][i].position>0 && map[layer][i-1].nextNodes.contains(defPos)){ //Default position taken by previous node use next node
                        //print("Default position taken using next for index  \(layer), \(i)")
                        map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)+1])
                    }
                    else if(map[layer][i].position>0 && !map[layer][i-1].nextNodes.contains(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])){
                        //Previous node hasn't used default position take theirs
                        map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])
                    }
                    else if(map[layer][i].nextNodes.contains(defPos)){ //If nodes was randomly chosen to have extra path add path before or after default
                        if(map[layer][i].position == map[layer].count-1){
                            map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])
                        }
                        else{
                            map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)+1])
                        }
                    }
                    else{ //default case
                        map[layer][i].nextNodes.append(defPos)
                    }
                    
                }
            }
            else if(map[layer+1].count < map[layer].count){ //Next row smaller
                let direction = encounterRng.nextInt(in: 0..<2)
                if(direction == 0){ //Bias Right
                    for node in map[layer] {
                        node.nextNodes = [map[layer+1][node.position*(map[layer+1].count-1)/(map[layer].count-1)]]
                    }
                }
                else{ //Bias Right
                    for node in map[layer] {
                        let proportion = Double(node.position) / Double(map[layer].count - 1)
                        let targetIndex = Int(round(proportion * Double(map[layer+1].count - 1)))
                        node.nextNodes = [map[layer+1][targetIndex]]
                    }
                }
            }
            else{ //Same size
                let extraPath = encounterRng.nextInt(in: 0..<map[layer].count) //give random node extra path
                for node in map[layer] {
                    node.nextNodes.append(map[layer+1][node.position])
                    if node == map[layer][extraPath]{
                        if(node.position==0){
                            node.nextNodes.append(map[layer+1][node.position+1])
                        }
                        else if(node.position==map[layer].count-1){
                            node.nextNodes.append(map[layer+1][node.position-1])
                        }
                        else{
                            let direction = encounterRng.nextInt(in: 1..<3)
                            direction == 1 ? node.nextNodes.append(map[layer+1][node.position-1]) : node.nextNodes.append(map[layer+1][node.position+1])
                        }
                    }
                }
            }
        }
        
        return map
    }
    func generateRune(enchant: Enchantment?) -> Rune{
        let temp: Int =  shufflingRng.nextInt(in: 0..<10000)
        var prob: Int = 0
        for i in (0...letterOccurence.count-1){
            if(temp>=prob&&temp<prob+Int(letterOccurence[i]*100)){
                let char = Character(UnicodeScalar(i+97)!)//convert int to lower case char based on ascii value
                var pow = 1 //set power based on rarity of letter
                if(letterOccurence[i]<1){pow = 3}
                else if(letterOccurence[i]<=3.3){pow = 2}
                return Rune(l: String(char), p: pow, e: enchant)
            }
            prob += Int(letterOccurence[i]*100)
        }
        
        return Rune(l: "a", p: 1, e: nil)
    }
    //Replaces grid with new letters drawing new enchantments from the deck
    func shuffleGrid(){
        spell.removeAll()
        for i in (0..<gridSize){
            if(grid.count<=i){
                grid.append(generateRune(enchant: nil))
            }
            else{
                grid[i] = generateRune(enchant: nil)
            }
        }
        
        var enchantIndices: [Int] = []
        for _ in (0..<min(maxEnchants, spellBook.count)){
            var rand = shufflingRng.nextInt(in: 0..<gridSize)
            while(enchantIndices.contains(rand)){
                rand = shufflingRng.nextInt(in: 0..<gridSize)
            }
            enchantIndices.append(rand)
        }
        for index in enchantIndices {
            grid[index].enchant = drawEnchant()
        }
    }
    //Draws an enchantment at random from the deck reshuffling it if deck is empty.
    //Casting flag handles case were enchantments currently in the spell being cast should still be reshuffled
    func drawEnchant(casting: Bool = false) -> Enchantment?{
        if(spellBook.count==0){ return nil }
        if(spellDeck.isEmpty){ //Reshuffle all enchantments not on the grid
            spellDeck = spellBook
            for rune in grid{
                if(rune.enchant != nil && !(casting && spell.contains(rune))){
                    spellDeck.remove(at: spellDeck.firstIndex(of: rune.enchant!)!)
                }
            }
        }
        let rand = shufflingRng.nextInt(in: 0..<spellDeck.count)
        let enchant = spellDeck[rand]
        spellDeck.remove(at: rand)
        if(spellDeck.isEmpty){ //Reshuffle all enchantments not on the grid
            spellDeck = spellBook
            for rune in grid{
                if(rune.enchant != nil && (!casting || !spell.contains(rune))){
                    spellDeck.remove(at: spellDeck.firstIndex(of: rune.enchant!)!)
                }
            }
        }
        return enchant
        
    }
    //Helper Function For CheckValidSpell that builds a string from the runes
    func buildSpell() -> String {
        var temp:String = ""
        for rune in spell {
            temp.append(rune.letter)
        }
        return temp
    }
    func spellRuneSize() -> Double {
        if(spell.count<=4){ return 0.20}
        let len: Double = Double(spell.count)
        let temp: Double = 0.97-(0.01*Double(spell.count%4))
        return (temp/len)
    }
    /* Using IOSs built in dictionary to check if word is valid. This removes the need to struggle with reading in a file to
     reference. Word must also be at least length 4
     */
    func checkSpellValid(){
        let word = buildSpell()
        if(word.count < 4){
            validSpell = false
        }
        else{
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            validSpell = (misspelledRange.location == NSNotFound)
        }
    }
    func enemyTurn(){
        for enemy in enemies {
            let choice: Action = enemy.chooseAction(game: self)
            choice.utilizeEffect(game: self)
            if(player.block > 0){
                if(choice.damage > player.block){
                    player.currentHealth -= choice.damage + player.block
                    player.block = 0
                }
                else{
                    player.block -= choice.damage
                }
            }
            else{
                player.currentHealth -= choice.damage
            }
            applyRuneDebuffs(atk: choice)
        }
    }
    //Applies debuffs of an enemy attack to random runes that are not enchanted or debuffed
    func applyRuneDebuffs(atk: Action){
        if(player.nullify>0){ //Negates debuffs from an attack
            player.nullify -= 1
            return
        }
        var debuffable: Int = 0
        for rune in grid{
            if(rune.debuff == nil){
                debuffable += 1
            }
        }
        for i in 0..<atk.debuffs.count{
            var rand = shufflingRng.nextInt(in: 0..<debuffable-1) //assign the randth valid rune to be debuffed
            for rune in grid{
                if(rune.debuff == nil && rand > 0){
                    rand -= 1
                }
                if(rand == 0){
                    rune.debuff = atk.debuffs[i]
                    debuffable -= 1
                    break
                }
            }
        }
    }
    /*Since the effects of enchantments must be applied in a specific order this function creates an ordered list of all enchantments
    in the current spell. This is only needed to be run when there is both a valid target and word*/
    func queueEnchants(){
        enchantQueue.removeAll()
        for rune in grid{
            if(spell.contains(rune)&&rune.enchant != nil){
                for i in (0...enchantQueue.count){
                    if(i==enchantQueue.count){
                        enchantQueue.append(rune)
                    }
                    else if(rune.enchant!.priority>=enchantQueue[i].enchant!.priority){
                        enchantQueue.insert(rune, at: i)
                    }
                }
            }
        }
    }
    func castSpell(){
        //change grid size if surge letters used
        if(primaryTarget==nil){//select target warning
            print("no enemy targeted")
        }
        else{
            spellPower = 0
            queueEnchants()
            var enchantCount: Int = 0 //Number of un-used enchants on grid
            for rune in grid{ //count power and enchants
                if(spell.contains(rune)){
                    if(rune.debuff == nil || rune.debuff?.archetype != .weak){
                        spellPower += rune.power
                    }
                }
                else if(rune.enchant != nil){
                    enchantCount += 1
                }
            }
            print("spell power of \(spellPower) enchant count of \(enchantCount)")
            for rune in enchantQueue{
                rune.enchant?.utilizeEffect(game: self)
            }
            if(targets.max()==0.0){ //If no additional targets just hit primary target
                enemies[primaryTarget!].currentHealth -= Int(primaryModifer*Double(spellPower))
                if(enemies[primaryTarget!].currentHealth<=0){
                    SoundManager.shared.playSoundEffect(named: enemies[primaryTarget!].deathSound)
                }
                else{
                    SoundManager.shared.playSoundEffect(named: enemies[primaryTarget!].hitSound)
                }
            }
            else{
                for i in 0..<targets.count {
                    enemies[i].currentHealth -=  Int(targets[i]*primaryModifer*Double(spellPower))//Deal damage based on targets modifier rounding down
                    if(enemies[i].currentHealth<=0){
                        SoundManager.shared.playSoundEffect(named: enemies[i].deathSound)
                    }
                    else{
                        SoundManager.shared.playSoundEffect(named: enemies[i].hitSound)
                    }
                }
            }
            withAnimation{
                enemies.removeAll { $0.currentHealth <= 0 }
            }
            enchantQueue.removeAll()
            targets.removeAll()
            primaryTarget = nil
            for i in (0...gridSize-1){ //Replace used letters in grid
                if(spell.contains(grid[i])){
                    if(enchantCount < min(spellBook.count, maxEnchants)){
                        let rng = shufflingRng.nextInt(in: 0..<spellBook.count)
                        grid[i] = generateRune(enchant: drawEnchant(casting: true))
                        enchantCount += 1
                        print("gimme enchant")
                    }
                    else{
                        grid[i] = generateRune(enchant: nil)
                    }
                }
                else if(grid[i].enchant != nil){
                    enchantCount += 1
                }
            }
            spell.removeAll()
        }
    }
    
    //Triggers all active rune debuffs
    func runeDebuffs(){
        for i in (0...gridSize-1){
            switch grid[i].debuff?.archetype{
            case .none:
                break
            case .some(.lock):
                grid[i].debuff?.value -= 1
                if(grid[i].debuff!.value <= 0){
                    grid[i].debuff = nil
                }
            case .some(.scorch):
                player.currentHealth -= grid[i].debuff!.value
                grid[i] = generateRune(enchant: nil)
            case .some(.rot):
                player.currentHealth -= grid[i].debuff!.value
                grid[i].debuff?.value += 1
            case .some(.weak):
                grid[i].debuff?.value -= 1
                if(grid[i].debuff!.value <= 0){
                    grid[i].debuff = nil
                }
            }
        }
    }
    func selectRune(rune:Rune){
        if(!spell.contains(rune)){
            spell.append(rune)
            spellPower += rune.power
        }
        else{
            spell.removeSubrange(spell.firstIndex(of: rune)!..<spell.count) //removes the element and all following
        }
        selectedRune = rune
    }
    func selectNode(node: MapNode){
        //Change selectable
        encounterOver = false
        for node in map[node.layer]{
            node.selectable = false
        }
        for node in node.nextNodes{
            node.selectable = true
        }
    }
    func loadNode(node: NodeType){
        switch node{
        case .combat:
            if(!encounterOver){
                generateCombat()
                spellDeck = spellBook //Reset deck
                shuffleGrid() //Reset grid
            }
            else{
                generateEnchantRewards()
            }
        case .elite:
            return
        case .event:
            return
        case .rest:
            return
        case .shop:
            return
        }
    }
    
    func generateCombat(){
        combatCount += 1
        if let encounter = EncounterPool.shared.getRandomEncounter(forZone: .Forest, difficulty: combatCount%3+1) {
            enemies = encounter.generateEnemies()
        }
    }
    func generateEvent(){
        
    }
    func generateEnchantRewards(){
        for _ in (0..<3){
            rewardEnchants.append(spellLibrary[rewardRng.nextInt(in: (0..<spellLibrary.count))])
        }
    }
    func addEnchant(enchant: Enchantment.Type){
        spellBook.append(enchant.init())
        rewardEnchants = []
        encounterOver = false
    }
    //This functions handles clean up actions involved during combat and returns true if combat is over
    func cleanUp() -> Bool{
        if enemies.isEmpty{
            spellDeck = spellBook //Reset deck
            withAnimation(){
                encounterOver = true
            }
            return true
        }
        if player.currentHealth <= 0{
            withAnimation(){
                defeat = true
            }
        }
        player.block = 0
        return false
    }
}


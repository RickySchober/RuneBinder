//
//  RuneBinderGame.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import Foundation
import UIKit
import SwiftUI
class RuneBinderGame{
    //Spell Vars
    private (set) var grid: Array<Rune> = []
    private (set) var enchantQueue: Array<Rune> = []
    private var gridSize: Int = 16
    private (set) var spell: Array<Rune> = []
    private var spellBook: Array<Enchantment.Type> //List of known enchantments
    private var spellPower: Int = 0
    private (set) var validSpell: Bool = false
    private (set) var selectedRune: Rune? = nil
    
    private (set) var player: Player = Player(currentHealth: 50, maxHealth: 80)
    private (set) var enemies: [Enemy] = [] //Array containing the enemies in the current encounter will be in index 0-3 based on position
    private (set) var primaryTarget: Enemy? = nil //Each spell cast requires selecting an enemy as a target
    private (set) var targets: [Enemy] = [] //Runes that modify targeting will add additional enemies to list of targets
    
    //Map
    private (set) var map: [[MapNode]] = [[]]
    
    private (set) var victory: Bool = false
    private (set) var defeat: Bool = false

    //Array represents the relative occurence of letters in words in the dictionary
    //numbers represent the % of its occurence and correlate with A-Z
    private let letterOccurence: Array<Double> = [7.8, 2.0, 4.0, 3.8, 11, 1.4, 3.0, 2.3, 8.6, 0.21, 0.97, 5.3, 2.7, 7.2,
                                                  6.1, 2.8, 0.19, 7.3, 8.7, 6.7, 3.3, 1.0, 0.91, 0.27, 1.6, 0.44]
    init(){
        spellBook = [VampiricStrike.self, Empower.self, Revitalize.self]
        map = generateMap(numLayers: 10, minNodes: 3, maxNodes: 5)
        print(enemies.count)
        fillGrid()
    }
    //A function that generates the array of encounters on game start up
    func getSpellPower() -> Int{
        return spellPower
    }
    func getEnemies() -> [Enemy]{
        return enemies
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
    func addTarget(enemy:Enemy){
        var targetFound: Bool = false
        for target in targets{
            if(target == enemy){
                targetFound = true
                break
            }
        }
        if(!targetFound){
            targets.append(enemy)
        }
    }
    func changeTarget(enemy:Enemy){
        primaryTarget = enemy;
    }
    func generateMap(numLayers: Int, minNodes: Int, maxNodes: Int) -> [[MapNode]] {
        var map: [[MapNode]] = []
        while map.count < numLayers{
            map.append([])
        }
        for layer in 0..<numLayers {
            var nodeCount = Int.random(in: minNodes...maxNodes)
            while(layer >= 2  && nodeCount == map[layer-1].count && nodeCount == map[layer-2].count){ //Prevent many same size in a row
                nodeCount = Int.random(in: minNodes...maxNodes)
            }
            for i in 0..<nodeCount{
                map[layer].append(MapNode(pos: i, lay: layer, tp: .combat))
                if(layer==0){
                    map[layer][i].selectable = true
                }
            }
            
        }
        print(map)
        //Adds connections between layers of node depending on relative size of this layer and next layer
        for layer in 0..<(numLayers - 1) {
            let posScale = (map[layer+1].count-1)/(map[layer].count-1)
            
            if(map[layer+1].count > map[layer].count){ //Next row bigger
                let extraPaths = map[layer+1].count - map[layer].count //Randomly assign extra paths
                for _ in 0..<extraPaths{
                    var randPos = Int.random(in: 0..<map[layer].count)
                    while(!map[layer][randPos].nextNodes.isEmpty){
                        randPos = Int.random(in: 0..<map[layer].count)
                    }
                    map[layer][randPos].nextNodes = [map[layer+1][map[layer][randPos].position*(map[layer+1].count-1)/(map[layer].count-1)]]
                }
                for i in 0..<map[layer].count {
                    var defPos = map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)]
                    if(map[layer][i].position>0 && !map[layer][i-1].nextNodes.contains(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])){
                        map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])
                    }
                    else if(map[layer][i].position>0 && map[layer][i-1].nextNodes.contains(defPos)){
                        map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)+1])
                    }
                    else if(map[layer][i].nextNodes.contains(defPos)){
                        if(map[layer][i].position == map[layer].count-1){
                            map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)-1])
                        }
                        else{
                            map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)+1])
                        }
                    }
                    else{
                        map[layer][i].nextNodes.append(map[layer+1][map[layer][i].position*(map[layer+1].count-1)/(map[layer].count-1)])
                    }
                    
                }
            }
            else if(map[layer+1].count < map[layer].count){ //Next row smaller
                for node in map[layer] {
                    node.nextNodes = [map[layer+1][node.position*(map[layer+1].count-1)/(map[layer].count-1)]]
                }
            }
            else{ //Same size
                for node in map[layer] {
                    let connections = Int.random(in: 1...4)
                    node.nextNodes.append(map[layer+1][node.position])
                    if connections == 4{
                        if(node.position==0){
                            node.nextNodes.append(map[layer+1][node.position+1])
                        }
                        else if(node.position==map[layer].count-1){
                            node.nextNodes.append(map[layer+1][node.position-1])
                        }
                        else{
                            let direction = Int.random(in: 1...2)
                            direction == 1 ? node.nextNodes.append(map[layer+1][node.position-1]) : node.nextNodes.append(map[layer+1][node.position+1])
                        }
                    }
                }
            }
        }
        
        return map
    }
    func generateRune(enchant: Enchantment?) -> Rune{
        let temp =  Double.random(in: 0..<100)
        var prob: Double = 0.0
        for i in (0...letterOccurence.count-1){
            if(temp>=prob&&temp<prob+letterOccurence[i]){
                let char = Character(UnicodeScalar(i+97)!)//convert int to lower case char based on ascii value
                var pow = 1 //set power based on rarity of letter
                if(letterOccurence[i]<1){pow = 3}
                else if(letterOccurence[i]<=3.3){pow = 2}
                return Rune(l: char, p: pow, e: enchant)
            }
            prob += letterOccurence[i]
        }
        
        return Rune(l: "a", p: 1, e: nil)
    }
    func fillGrid(){
        var i = 0
        while(grid.count<gridSize){
            grid.append(generateRune(enchant: nil))
            i = i + 1
        }
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
            player.currentHealth -= choice.damage
            applyRuneDebuffs(atk: choice)
            print(player.currentHealth)
        }
    }
    //Applies debuffs of an enemy attack to random runes that are not enchanted or debuffed
    func applyRuneDebuffs(atk: Action){
        var debuffable: Int = 0
        for rune in grid{
            if(rune.enchant == nil && rune.rot == 0 && rune.scorch == 0 && rune.lock == 0 && rune.weaken == 0){
                debuffable += 1
            }
        }
        print(debuffable)
        for _ in 0..<atk.lock{
            var rand = Int.random(in: 0..<debuffable-1)
            for rune in grid{
                if(rune.enchant == nil && rune.rot == 0 && rune.scorch == 0 && rune.lock == 0 && rune.weaken == 0){
                    rand -= 1
                }
                if(rand == 0){
                    rune.lock += 1
                    debuffable -= 1
                    break
                }
            }
        }
        for _ in 0..<atk.weaken{
            var rand = Int.random(in: 0..<debuffable-1)
            for rune in grid{
                if(rune.enchant == nil && rune.rot == 0 && rune.scorch == 0 && rune.lock == 0 && rune.weaken == 0){
                    rand -= 1
                }
                if(rand == 0){
                    rune.weaken += 1
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
            addTarget(enemy: primaryTarget!) //must add primary target to list of targets before resolving spell effects
            queueEnchants()
            for i in (0...gridSize-1){ //Replace used letters in grid
                if(spell.contains(grid[i])){
                    if(grid[i].weaken == 0){
                        spellPower += grid[i].power
                    }
                    let rng = Int.random(in: 0...(spellBook.count-1))
                    grid[i] = generateRune(enchant: spellBook[rng].init())
                }
            }
            for rune in enchantQueue{
                rune.enchant?.utilizeEffect(game: self)
            }
            for target in targets {
                target.currentHealth -= spellPower
                if(target.currentHealth<=0){
                    SoundManager.shared.playSoundEffect(named: target.deathSound)
                }
                else{
                    SoundManager.shared.playSoundEffect(named: target.hitSound)
                }
            }
            withAnimation{
                enemies.removeAll { $0.currentHealth <= 0 }
            }
            enchantQueue.removeAll()
            spell.removeAll()
            targets.removeAll()
            primaryTarget = nil
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
        
    }
    func selectNode(node: MapNode){
        //Change selectable
        for node in map[node.layer]{
            node.selectable = false
        }
        for node in node.nextNodes{
            node.selectable = true
        }
        switch node.type{
        case .combat:
            generateCombat()
        case .elite:
            return
        case .event:
            return
        case .rest:
            return
        case .shop:
            return
        case nil:
            return
        }
    }
    
    func generateCombat(){
        enemies = [ChainBearer(pos: 1), ChainBearer(pos: 2), Goblin(pos: 3), Goblin(pos: 4)]
    }
    func generateEvent(){
        
    }
    //This functions handles clean up actions involved during combat 
    func cleanUp(){
        if enemies.isEmpty{
            withAnimation(){
                victory = true
            }
        }
        if player.currentHealth <= 0{
            withAnimation(){
                defeat = true
            }
        }
    }
}


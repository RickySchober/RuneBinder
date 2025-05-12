//
//  RuneBinderGame.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import Foundation
import UIKit
import SwiftUI
struct RuneBinderGame{
    private (set) var grid: Array<Rune>
    private (set) var enchantQueue: Array<Rune>
    private var gridSize: Int = 16
    private (set) var spell: Array<Rune>
    private var spellBook: Array<Enchantment.Type> //List of known enchantments
    private var spellPower: Int = 0
    private (set) var player: Player = Player(currentHealth: 50, maxHealth: 80)
    private (set) var enemies: [Enemy] = [] //Array containing the enemies in the current encounter will be in index 0-3 based on position
    private (set) var primaryTarget: Enemy? = nil //Each spell cast requires selecting an enemy as a target
    private (set) var targets: [Enemy] = [Enemy(pos: 1)] //Runes that modify targeting will add additional enemies to list of targets
    private (set) var validSpell: Bool = false
    //Array represents the relative occurence of letters in words in the dictionary
    //numbers represent the % of its occurence and correlate with A-Z
    private let letterOccurence: Array<Double> = [7.8, 2.0, 4.0, 3.8, 11, 1.4, 3.0, 2.3, 8.6, 0.21, 0.97, 5.3, 2.7, 7.2,
                                                  6.1, 2.8, 0.19, 7.3, 8.7, 6.7, 3.3, 1.0, 0.91, 0.27, 1.6, 0.44]
    private var dictionary: Array<String>
    init(){
        grid = []
        spell = []
        dictionary = []
        enchantQueue = []
        spellBook = [VampiricStrike.self, Empower.self, Revitalize.self]
        enemies = generateEnemies()
        print(enemies.count)
        //dictionary = readCSV()
        fillGrid()
    }
    //A function that generates the array of encounters on game start up
    func getSpellPower() -> Int{
        return spellPower
    }
    func getEnemies() -> [Enemy]{
        return enemies
    }
    mutating func changeHealth(num:Int){
        if(player.currentHealth+num>player.maxHealth){ player.currentHealth = player.maxHealth }
        else{ player.currentHealth += num }
    }
    mutating func changeSpellPower(num:Int){
        spellPower += num
    }
    mutating func addTarget(enemy:Enemy){
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
    mutating func changeTarget(enemy:Enemy){
        primaryTarget = enemy;
    }
    func generateEnemies() -> [Enemy]{
        return [Goblin(pos: 1),Enemy(pos: 2)]
    }
    /* Function reads from the local CSV file in the applications documents folder and saves it as an array of strings
       Because I am using simultaor right now had to manually go into the filepath and add it to this specific version (iphone 14 pro)
     */
    func readCSV() -> Array<String> {
        let fileExtension = URL(fileURLWithPath: "out.csv").pathExtension
        let fileName = URL(fileURLWithPath: "out.csv").deletingPathExtension().lastPathComponent
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let inputFile = fileURL.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        do {
            let savedFile = try String(contentsOf: inputFile)
            return savedFile.components(separatedBy: "\n") //Each new line is a word so they seperate by \n
        }
        catch {
            print("read has failed")
            return []
        }
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
    mutating func fillGrid(){
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
        if(spell.count<=4){ return 0.24}
        let len: Double = Double(spell.count)
        let temp: Double = 0.97-(0.01*Double(spell.count%4))
        return (temp/len)
    }
    /* Using IOSs built in dictionary to check if word is valid. This removes the need to struggle with reading in a file to
     reference. Word must also be at least length 4
     */
    mutating func checkSpellValid(){
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
    
   /* mutating func checkSpellValid(){
        let word = buildSpell()
        var low  = 0
        var high = dictionary.count
        print(word)
        while(low <= high){
            let mid = (low+high)/2
            if(dictionary[mid].caseInsensitiveCompare(word) == .orderedSame){ print("gottem")
                return validSpell = true  }
            else if(dictionary[mid].caseInsensitiveCompare(word) == .orderedAscending){  low = mid+1  }
            else{  high = mid-1  }
        }
        validSpell = false
    }*/
    /*Since the effects of enchantments must be applied in a specific order this function creates an ordered list of all enchantments
    in the current spell. This is only needed to be run when there is both a valid target and word*/
    mutating func queueEnchants(){
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
    mutating func castSpell(){
        //change grid size if surge letters used
        if(primaryTarget==nil){//select target warning
            print("no enemy targeted")
        }
        else{
            spellPower = 0
            addTarget(enemy: primaryTarget!) //must add primary target to list of targets before resolving spell effects
            queueEnchants()
            for i in (0...gridSize-1){
                if(spell.contains(grid[i])){
                    spellPower += grid[i].power
                    let rng = Int.random(in: 0...(spellBook.count-1))
                    grid[i] = generateRune(enchant: spellBook[rng].init())
                }
            }
            for rune in enchantQueue{
                rune.enchant?.utilizeEffect(game: &self)
            }
            enchantQueue.removeAll()
            spell.removeAll()
            //targets.removeAll()
            primaryTarget = nil
        }
    }
    mutating func selectRune(rune:Rune){
        if(!spell.contains(rune)){
            spell.append(rune)
            spellPower += rune.power
        }
        else{
            spell.removeSubrange(spell.firstIndex(of: rune)!..<spell.count) //removes the element and all following
        }
        
    }
}


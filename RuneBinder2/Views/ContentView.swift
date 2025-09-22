//
//  ContentView.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//

import SwiftUI

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}

struct ContentView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel //Environment objects can be shared among all views
    @EnvironmentObject var viewRouter: ViewRouter
    @Namespace private var runesNamespace //Used to animate between views
    @State private var deckViewer: Bool = false
    var body: some View {
        ZStack(){
            VStack(spacing:0){
                CombatView()
                    .frame(width: screenWidth, height: screenHeight*0.9-screenWidth*1.05)
                    .background(.blue)
                RuneGrid(namespace: runesNamespace)
                    .background(.yellow)
                SpellView(namespace: runesNamespace)
                    .frame(width: screenWidth, height: screenWidth*0.20) //Reserve this space for view regardless of adjusted size
                    .background(.green)
                HStack(){
                    Button(action:{
                        viewModel.validSpell ? self.viewModel.castSpell() : print("your bad")
                    }, label: {Text("Cast Spell")
                            .font(.system(size: 40.0))
                    })
                    Button(action:{
                     self.viewModel.shuffleGrid()
                    }, label: {Text("Scramble")
                            .font(.system(size: 40.0))
                    })
                    Button(action:{
                     deckViewer = true
                    }, label: {Text("Deck")
                            .font(.system(size: 40.0))
                    })
                }
                .background(viewModel.validSpell ? Color.gray : Color.yellow )
                .frame(width: screenWidth, height: screenHeight*0.1, alignment: .center)
                .scaledToFill()
            }
            .edgesIgnoringSafeArea(.top)
            //.frame(width: screenWidth, height: screenHeight)
            .background(Color.red.opacity(0.3))
            //.animation(.easeOut)
            VictoryOverlay() {
                viewRouter.currentScreen = .map
            }
            .offset(y: viewModel.victory ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: viewModel.victory)
            EnchantmentGridView(enchantments: viewModel.spellDeck)
            .offset(y: deckViewer ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: deckViewer)
        }
        .onTapGesture {
            deckViewer = false
        }
    }
}


struct EnemyView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var enemy: Enemy
    
    var healthRatio: CGFloat {
        CGFloat(enemy.currentHealth) / CGFloat(enemy.maxHealth)
       }
    var body: some View{
        VStack(spacing: 0){
            ZStack(alignment: .leading) { //HP bar
                Rectangle()
                    .frame(width: screenWidth*0.13, height: screenHeight*0.0075)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(3)
                
                Rectangle()
                    .frame(width: max(0, screenWidth*0.13*healthRatio), height: screenHeight*0.0075) // 50 is total width
                    .foregroundColor(.red)
                    .cornerRadius(3)
                
                Text("\(enemy.currentHealth)/\(enemy.maxHealth)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(width: screenWidth*0.13, height: screenHeight*0.02)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: screenWidth*0.18)
            HStack(){
                if(enemy.bleedDamage != 0){
                    ZStack(alignment: .bottom){
                        GeometryReader{ geometry in
                            Image("bleed 1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                                .padding(0)
                            Text("\(enemy.bleedDamage)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .position(x: 0.8*geometry.size.width, y: 0.8*geometry.size.height)
                                .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                                .padding([.bottom, .trailing], 1)
                        }
                    }
                    .frame(width: screenWidth*0.04, height: screenWidth*0.04)
                }
            }
            .frame(alignment: .leading)
            Image(enemy.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth*0.18, height: screenWidth*0.18)
                .clipped()
                .onTapGesture{ viewModel.selectEnemy(enemy: enemy)
                }
        }
        .transition(.asymmetric(insertion: .identity , removal: .opacity)) //animates insertion and deletion of view
    }
}

struct RuneGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State private var showTooltip: Bool = false
    @State private var tooltipRune: Rune? = nil
    @State private var tooltipPosition: CGPoint = .zero
    var namespace: Namespace.ID
    var body: some View {
        let columns = [
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0)
        ]
        LazyVGrid(columns: columns, spacing: 0 ){//Grid with 4 columns
            ForEach(self.viewModel.grid){ runes in
                if(!viewModel.spell.contains(runes)){
                    RuneView(rune: runes, namespace: namespace)
                        .aspectRatio(contentMode: .fit)
                        .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) {
                                [runes.id: $0]
                            }
                }
                else{
                    Rectangle()
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: screenWidth*0.20, height: screenWidth*0.20)
                        .background(Rectangle().fill(Color.mint))
                }
            }
        }
        .frame(width: screenWidth*0.8, height: screenWidth*0.8)
        .overlayPreferenceValue(RunePositionPreferenceKey.self) { preferences in
            GeometryReader { geo in
                ForEach(viewModel.grid) { rune in
                    if let anchor = preferences[rune.id], rune.id == viewModel.selectedRune?.id {
                        let point = geo[anchor]
                        RuneTooltipView(rune: rune)
                            .position(smartTooltipPosition(from: point, in: geo.size))
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

func smartTooltipPosition(from point: CGPoint, in containerSize: CGSize) -> CGPoint {
    let tooltipWidth: CGFloat = 120
    let tooltipHeight: CGFloat = 80
    let padding: CGFloat = 10

    var x = point.x + tooltipWidth / 2 + padding
    var y = point.y

    if x + tooltipWidth / 2 > containerSize.width {
        x = point.x - tooltipWidth / 2 - padding
    }

    if y + tooltipHeight / 2 > containerSize.height {
        y = containerSize.height - tooltipHeight / 2 - padding
    } else if y - tooltipHeight / 2 < 0 {
        y = tooltipHeight / 2 + padding
    }

    return CGPoint(x: x, y: y)
}


struct RunePositionPreferenceKey: PreferenceKey {
    static var defaultValue: [UUID: Anchor<CGPoint>] = [:]
    
    static func reduce(value: inout [UUID: Anchor<CGPoint>], nextValue: () -> [UUID: Anchor<CGPoint>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


struct RuneTooltipView: View {
    var rune: Rune

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let enchant = rune.enchant {
                Text(enchant.description)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if(rune.debuff != nil){
                Text(rune.debuff!.text)
            }
            else{
                Text("Basic \(String(rune.letter)) rune")
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.85))
        .cornerRadius(10)
        .foregroundColor(.white)
        .frame(maxWidth: 200)
        .shadow(radius: 5)
    }
}

struct SpellView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var namespace: Namespace.ID
    var body: some View {
        HStack(alignment: .top){
            ForEach(self.viewModel.spell, id: \.id){ runes in
                RuneView(rune: runes, namespace: namespace)
                        .padding(-3)
            }
        }
        .frame(width: min(screenWidth,(screenWidth/4.0*(CGFloat)(viewModel.spell.count))), height: screenWidth*CGFloat(viewModel.spellRuneSize)) //adjust allocated width with spell length
    }
}
struct EnemyListView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: -10) {
            ForEach(self.viewModel.enemies, id: \.id) { enemy in
                EnemyView(enemy: enemy)
                    .padding(0)
                    .background((viewModel.targets.contains(enemy)) ? Color.red.opacity(0.3) : Color.clear)
                    .cornerRadius(10)
            }
        }
        .animation(.default, value: viewModel.enemies)
    }
}
struct PlayerInfoView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel

    var healthRatio: CGFloat {
        CGFloat(viewModel.player.currentHealth) / CGFloat(viewModel.player.maxHealth)
       }
    var blockRatio: CGFloat {
        CGFloat(viewModel.player.block) / CGFloat(viewModel.player.maxHealth)
    }
    var body: some View {
        VStack {
            if(viewModel.player.block>0){
                ZStack(alignment: .leading) { //Block bar
                    Rectangle()
                        .frame(height: screenHeight*0.0075)
                        .foregroundColor(.gray.opacity(0.3))
                        .cornerRadius(3)
                    
                    Rectangle()
                        .frame(width: screenWidth*0.18*min(1 ,blockRatio), height: screenHeight*0.0075) // 50 is total width
                        .foregroundColor(.blue)
                        .cornerRadius(3)
                    
                    Text("\(viewModel.player.block)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .frame(width: screenWidth*0.18, height: screenHeight*0.02)
                        .minimumScaleFactor(0.5)
                }
                .frame(width: screenWidth*0.18)
                .padding(0)
            }
            ZStack(alignment: .leading) { //HP bar
                Rectangle()
                    .frame(height: screenHeight*0.0075)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(3)
                
                Rectangle()
                    .frame(width: screenWidth*0.18*healthRatio, height: screenHeight*0.0075) // 50 is total width
                    .foregroundColor(.red)
                    .cornerRadius(3)
                
                Text("\(viewModel.player.currentHealth)/\(viewModel.player.maxHealth)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(width: screenWidth*0.18, height: screenHeight*0.02)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: screenWidth*0.18)
            .padding(0)
            Image("player")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth*0.18, height: screenWidth*0.18)
                .clipped()
        }
    }
}

struct CombatView: View {
    var body: some View {
        ZStack(){
            Image("forest_bg1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            VStack(){
                Spacer()
                HStack(alignment: .bottom) {
                    // Player on the left
                    PlayerInfoView()
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Spacer()
                        .padding()
                    
                    // Enemies on the right
                    EnemyListView()
                }
                .frame(width: screenWidth)
                .padding(0)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
            }
            .frame(minHeight: screenHeight*0.9-screenWidth*1.05)
        }
    }
}

struct VictoryOverlay: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Victory")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            HStack(spacing: 15){
                ForEach(viewModel.rewardEnchants.indices, id: \.self) { index in
                    let enchant = viewModel.rewardEnchants[index].init()
                    Text(enchant.description)
                        .padding()
                        .background(enchant.color.opacity(0.8))
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.selectReward(enchant: viewModel.rewardEnchants[index])
                            viewRouter.currentScreen = .map
                        }
                }
            }
            Button("Continue", action: onContinue)
                .font(.headline)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.8))
        .cornerRadius(20)
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RuneBinderViewModel())
    }
}

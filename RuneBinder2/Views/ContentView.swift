//
//  ContentView.swift
//  RuneBinder
//
//  Created by Ricky Schober on 11/11/22.
//  Always explicit typing in views to avoid large compile times

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
    @State private var entityTooltipSize: CGSize = .zero
    @State private var runeTooltipSize: CGSize = .zero
    var body: some View {
        ZStack(){
            VStack(spacing:0){
                CombatView()
                    .frame(width: screenWidth, height: screenHeight*0.9-screenWidth*1.15)
                    .background(.blue)
                ImageBorderView(
                    cornerImage: "wood_corner",
                    edgeVert: "wood_border",
                    edgeHori: "wood_border2",
                    cornerSize: 24,
                    edgeThickness: 16
                ) {
                    SpellView(namespace: runesNamespace)
                        .frame(width: screenWidth-32, height: screenWidth*0.20) //Reserve this space for view regardless of adjusted size
                }
                RuneGrid(namespace: runesNamespace)
                    .background(.yellow)
                HStack(){
                    Button(action:{
                        viewModel.validSpell ? self.viewModel.castSpell() : print("your bad")
                    }, label: {Text("Cast Spell")
                    })
                    .runeBinderButtonStyle()
                    Button(action:{
                     self.viewModel.shuffleGrid()
                    }, label: {Text("Scramble")
                    })
                    .runeBinderButtonStyle()
                    Button(action:{
                     deckViewer = true
                    }, label: {Text("Deck")
                    })
                    .runeBinderButtonStyle()
                }
                .background(viewModel.validSpell ? Color.gray : Color.yellow )
                .frame(width: screenWidth, height: screenHeight*0.1, alignment: .center)
            }
            .allowsHitTesting(!viewModel.isAnimatingTurn)
            .edgesIgnoringSafeArea(.top)
            .background(Color.red.opacity(0.3))
            VictoryOverlay() {
                viewModel.returnToMap()
                viewRouter.currentScreen = .map
            }
            .offset(y: viewModel.encounterOver ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: viewModel.encounterOver)
            EnchantmentGridView(enchantments: viewModel.spellDeck) //Empty 
            .offset(y: deckViewer ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: deckViewer)
        }
        //Entity Description overlay
        .overlayPreferenceValue(RunePositionPreferenceKey.self) { preferences in
            GeometryReader { geo in
                ForEach(viewModel.enemies) { enemy in
                    if let anchor: Anchor<CGPoint> = preferences[enemy.id], viewModel.hoveredEntity?.id == enemy.id {
                        let point: CGPoint = geo[anchor]
                        EntityTooltipView(entity: enemy)
                            .sizeReader(size: $entityTooltipSize)
                            .position(entityTooltipPosition(from: point, tooltipSize: entityTooltipSize, in: CGSize(width: screenWidth, height: screenHeight)))
                            .transition(.opacity)
                    }
                }
            }
        }
        //Rune Description Overlay
        .overlayPreferenceValue(RunePositionPreferenceKey.self) { preferences in
            GeometryReader { geo in
                ForEach(viewModel.grid) { rune in
                    if let anchor: Anchor<CGPoint> = preferences[rune.id], rune.id == viewModel.hoveredRune?.id {
                        let point: CGPoint = geo[anchor]
                        RuneTooltipView(rune: rune)
                            .sizeReader(size: $runeTooltipSize)
                            .position(runeTooltipPosition(from: point, tooltipSize: runeTooltipSize, in: CGSize(width: screenWidth, height: screenHeight)))
                            .transition(.opacity)
                    }
                }
            }
        }
        //Floating Text Overlay
        .overlayPreferenceValue(RunePositionPreferenceKey.self) { preferences in
            GeometryReader { geo in
                ForEach(viewModel.floatingTexts) { text in
                    ForEach(viewModel.enemies) { enemy in
                        if let anchor: Anchor<CGPoint> = preferences[enemy.id], text.entityId == enemy.id {
                            let point: CGPoint = geo[anchor]
                            FloatingTextView(text: text.text, color: text.color)
                                .position(point)
                                .transition(.opacity)
                        }
                    }
                    ForEach(viewModel.grid){ rune in
                        if let anchor: Anchor<CGPoint> = preferences[rune.id], text.entityId == rune.id {
                            let point: CGPoint = geo[anchor]
                            FloatingTextView(text: text.text, color: text.color)
                                .position(point)
                                .transition(.opacity)
                        }
                    }
                    if let anchor: Anchor<CGPoint> = preferences[viewModel.player.id], text.entityId == viewModel.player.id {
                        let point: CGPoint = geo[anchor]
                        FloatingTextView(text: text.text, color: text.color)
                            .position(point)
                            .transition(.opacity)
                    }
                }
            }
        }
        .onTapGesture {
            deckViewer = false
        }
    }
}

struct RuneGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State private var showTooltip: Bool = false
    @State private var tooltipRune: Rune? = nil
    @State private var tooltipPosition: CGPoint = .zero
    var namespace: Namespace.ID
    var body: some View {
        ZStack{
            let columns = [
                GridItem(.flexible(),spacing: 0),
                GridItem(.flexible(),spacing: 0),
                GridItem(.flexible(),spacing: 0),
                GridItem(.flexible(),spacing: 0)
            ]
            ImageBorderView(
                cornerImage: "wood_corner",
                edgeVert: "wood_border",
                edgeHori: "wood_border2",
                cornerSize: 24,
                edgeThickness: 16
            ) {
                LazyVGrid(columns: columns, spacing: 0 ){//Grid with 4 columns
                    ForEach(self.viewModel.grid, id: \.id){ runes in
                        if(!viewModel.spell.contains(runes)){
                            RuneView(rune: runes, namespace: namespace)
                                .aspectRatio(contentMode: .fit)
                                .zIndex(viewModel.hoveredRune == runes ? 999 : 0)
                        }
                        else{
                            Color.clear
                                .fixedSize(horizontal: true, vertical: true)
                                .frame(width: screenWidth*0.20, height: screenWidth*0.20)
                        }
                    }
                }
                .frame(width: screenWidth*0.8, height: screenWidth*0.8)
            }
        }
    }
}
func entityTooltipPosition(from point: CGPoint, tooltipSize: CGSize, in containerSize: CGSize) -> CGPoint {
    let tooltipWidth: CGFloat = tooltipSize.width
    let tooltipHeight: CGFloat = tooltipSize.height
    let padding: CGFloat = screenWidth*0.09 //padding based on enemy image size

    var x = point.x
    var y = point.y

    if x + tooltipWidth + padding > containerSize.width { //If tooltip on right goes offscreen try on left
        if !(x - tooltipWidth - padding < 0) { //If tooltip on left doesn't go offscreen put there
            x -= tooltipWidth / 2 + padding
        }
        else{
            x = tooltipWidth/2 + padding
        }
    }
    else{
        x = point.x + tooltipWidth / 2 + padding //place right by default
    }
    
    if y - tooltipHeight/2 < 0{ //If offscreen on top move down
        y += tooltipHeight/2-y
    }
            
    return CGPoint(x: x, y: y)
}
/* Function for positioning runeTooltip based on parameters:
    point: center coordinate of rune
    tooltipSize: full size of tooltip
    container: area that the tooltip must fit inside usually just the screen
 */
func runeTooltipPosition(from point: CGPoint, tooltipSize: CGSize, in containerSize: CGSize) -> CGPoint {
    let tooltipWidth: CGFloat = tooltipSize.width
    let tooltipHeight: CGFloat = tooltipSize.height
    let padding: CGFloat = screenWidth*0.1 //padding based one runeSize

    var x = point.x
    var y = point.y

    if x + tooltipWidth + padding > containerSize.width { //If tooltip on right goes offscreen try on left
        if !(x - tooltipWidth - padding < 0) { //If tooltip on left doesn't go offscreen put there
            x -= tooltipWidth / 2 + padding
        }
        else{
            x = tooltipWidth/2 + padding
        }
    }
    else{
        x = point.x + tooltipWidth / 2 + padding //place right by default
    }
    
    if y + tooltipHeight/2 > containerSize.height{ //If offscreen on bottom move up
        y -= tooltipHeight/2+y - containerSize.height
        print("offscreen on bottom")
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
    let widthRatio = 0.45
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let enchant = rune.enchant {
                VStack{
                    Image(rune.enchant!.image)
                        .resizable()
                        .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                    Text(enchant.description)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .frame(width: screenWidth*widthRatio)
                .tooltipStyle()
            }
            else if(rune.debuff == nil){
                Text("Basic \(String(rune.letter)) rune")
                    .frame(width: screenWidth*widthRatio)
                    .tooltipStyle()
            }
            if(rune.debuff != nil){
                VStack{
                    Image(rune.debuff!.image)
                        .resizable()
                        .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                    Text(rune.debuff!.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .frame(width: screenWidth*widthRatio)
                .tooltipStyle()
            }
        }
        .frame(width: screenWidth*widthRatio)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(radius: 5)
    }
}

struct EntityTooltipView: View {
    var entity: Entity
    let widthRatio = 0.45
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if(entity is Enemy){
                let enemy: Enemy = entity as! Enemy
                VStack{
                    HStack(){
                        Text("Attack")
                            .bold()
                            .foregroundStyle(.yellow)
                        Image("attack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 0.05*screenWidth, height: 0.05*screenWidth)
                        Spacer()
                    }
                    Text("Attacking for \(enemy.chosenAction!.damage)")
                        .frame(width: screenWidth*widthRatio)
                }
                .tooltipStyle()
                .frame(width: screenWidth*widthRatio)
                
            }
            ForEach(entity.debuffs){ debuff in
                VStack{
                    HStack{
                        Text(debuff.image)
                        Image(debuff.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 0.05*screenWidth, height: 0.05*screenWidth)
                    }
                    Text(debuff.text)
                }
                .tooltipStyle()
                .frame(width: screenWidth*widthRatio)
            }
            ForEach(entity.buffs){ buff in
                VStack{
                    HStack{
                        Text(buff.image)
                        Image(buff.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 0.05*screenWidth, height: 0.05*screenWidth)
                    }
                    Text(buff.text)
                }
                .tooltipStyle()
                .frame(width: screenWidth*widthRatio)
            }
        }
        .frame(width: screenWidth*widthRatio)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(radius: 5)
    }
}
struct SpellView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var namespace: Namespace.ID
    var body: some View {
        HStack(alignment: .top, spacing: 0){
            ForEach(self.viewModel.spell, id: \.id){ runes in
                RuneView(rune: runes, namespace: namespace)
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
                        .background((viewModel.target == enemy) ? Color.red.opacity(0.3) : Color.clear)
                        .zIndex(viewModel.lunge == enemy.id ? 10 : 0)
            }
        }
        .animation(.default, value: viewModel.enemies)
    }
}

struct CombatView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        ZStack {
            // Background
            Image("forest_bg1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: screenWidth)
                .ignoresSafeArea()
            
            Rectangle()
                .fill(
                    ImagePaint(image: Image("grasstile"),
                               sourceRect: CGRect(x: 0, y: 0, width: 1, height: 1),
                               scale: 0.2)
                )
                .frame(width: screenWidth*2, height: screenHeight * 0.5)
                .rotation3DEffect(
                    .degrees(70),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom
                )
                .offset(y: screenHeight * -0.03)
            // Characters anchored to ground
            VStack{
                Spacer()
                HStack(alignment: .bottom) {
                    // Player on left
                    PlayerView(player: viewModel.player)
                        .padding(.leading, screenWidth*0.51)
                    Spacer()
                    // Enemies on right
                    EnemyListView()
                        .padding(.trailing, screenWidth*0.51)
                }
                .padding(.bottom, screenWidth*0.18)
            }
        }
    }
}

struct VictoryOverlay: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    let onContinue: () -> Void
    var body: some View {
        ImageBorderView(
            cornerImage: "wood_corner",
            edgeVert: "wood_border",
            edgeHori: "wood_border2",
            cornerSize: 24,
            edgeThickness: 16
        ) {
            VStack(spacing: 10) {
                Text("Victory")
                    .runeBinderButtonStyle()
                Text("Select a rune to add to spell library:")
                    .runeBinderButtonStyle()
                VStack(spacing: 10){
                    ForEach(viewModel.rewardEnchants.indices, id: \.self) { index in
                        let enchant = viewModel.rewardEnchants[index].init()
                        HStack(alignment: .center, spacing: 1) {
                            Image(enchant.image)
                                .resizable()
                                .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                                .padding(screenWidth*0.01)
                                .runeTileStyle(shadowDepth: 0.09)
                            Text(enchant.description)
                                .font(.custom("Trattatello", size: 0.05*screenWidth))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                        }
                        .frame(width: screenWidth*0.8, height: screenWidth*0.2)
                        .runeBinderButtonStyle()
                        .onTapGesture {
                            viewModel.selectReward(enchant: viewModel.rewardEnchants[index])
                            viewModel.returnToMap()
                            viewRouter.currentScreen = .map
                        }
                    }
                }
                Button("Continue", action: onContinue)
                    .runeBinderButtonStyle()
                    .padding(.bottom, 10)
            }
            .padding(10)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RuneBinderViewModel())
    }
}

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
            .edgesIgnoringSafeArea(.top)
            //.frame(width: screenWidth, height: screenHeight)
            .background(Color.red.opacity(0.3))
            //.animation(.easeOut)
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
        .onTapGesture {
            deckViewer = false
        }
    }
}
struct ImageBorderView<Content: View>: View {
    let content: Content
    let cornerImage: String
    let edgeVert: String
    let edgeHori: String
    let cornerSize: CGFloat
    let edgeThickness: CGFloat

    init(
        cornerImage: String,
        edgeVert: String,
        edgeHori: String,
        cornerSize: CGFloat = 24,
        edgeThickness: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerImage = cornerImage
        self.edgeHori = edgeHori
        self.edgeVert = edgeVert
        self.cornerSize = cornerSize
        self.edgeThickness = edgeThickness
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Content centered inside
            content
                .padding(edgeThickness + (cornerSize-edgeThickness)/2)
                .background(Color(red: 0.89, green: 0.66, blue: 0.43))
                .overlay(
            GeometryReader { geo in
                ZStack {
                    // Top & Bottom edges
                    VStack {
                        Image(edgeHori)
                            .resizable(resizingMode: .stretch)
                            .frame(height: edgeThickness)
                            .padding(.top, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                        Spacer()
                        Image(edgeHori)
                            .resizable(capInsets: EdgeInsets(.zero), resizingMode: .stretch)
                            .frame(height: edgeThickness)
                            .padding(.bottom, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(1.0), radius: edgeThickness/2)
                    }

                    // Left & Right edges
                    HStack {
                        Image(edgeVert)
                            .resizable(resizingMode: .stretch)
                            .frame(width: edgeThickness)
                            .padding(.leading, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                        Spacer()
                        Image(edgeVert)
                            .resizable(resizingMode: .stretch)
                            .rotationEffect(.degrees(180))
                            .frame(width: edgeThickness)
                            .padding(.trailing, (cornerSize-edgeThickness)/2)
                            .shadow(color: .black.opacity(0.5), radius: edgeThickness/2)
                    }

                    // --- Corners ---
                    VStack {
                        HStack {
                            Image(cornerImage)
                                .resizable()
                                .frame(width: cornerSize, height: cornerSize)
                            Spacer()
                            Image(cornerImage)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: cornerSize, height: cornerSize)
                        }
                        Spacer()
                        HStack {
                            Image(cornerImage)
                                .resizable()
                                .frame(width: cornerSize, height: cornerSize)
                            Spacer()
                            Image(cornerImage)
                                .resizable()
                                .rotationEffect(.degrees(180))
                                .frame(width: cornerSize, height: cornerSize)
                        }
                    }
                }
            }
            )
        }
    }
}

struct RuneGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State private var showTooltip: Bool = false
    @State private var tooltipRune: Rune? = nil
    @State private var tooltipPosition: CGPoint = .zero
    @State private var tooltipSize: CGSize = .zero
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
                                .zIndex(viewModel.selectedRune == runes ? 999 : 0)
                                .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) {
                                    [runes.id: $0]
                                }
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
            .overlayPreferenceValue(RunePositionPreferenceKey.self) { preferences in
                GeometryReader { geo in
                    ForEach(viewModel.grid) { rune in
                        if let anchor = preferences[rune.id], rune.id == viewModel.selectedRune?.id {
                            let point = geo[anchor]
                            RuneTooltipView(rune: rune)
                                .onPreferenceChange(TooltipSizePreferenceKey.self) { size in
                                                        tooltipSize = size
                                }
                                .position(smartTooltipPosition(from: point, tooltipSize: tooltipSize, in: CGSize(width: screenWidth, height: screenHeight)))
                                .transition(.opacity)
                        }
                    }
                }
            }
        }
    }
}

func smartTooltipPosition(from point: CGPoint, tooltipSize: CGSize, in containerSize: CGSize) -> CGPoint {
    let tooltipWidth: CGFloat = tooltipSize.width
    let tooltipHeight: CGFloat = tooltipSize.height
    let padding: CGFloat = 10

    var x = point.x
    var y = point.y

    if x + tooltipWidth / 2 > containerSize.width {
        x = point.x - tooltipWidth / 2 - padding
    } else if x - tooltipWidth / 2 < 0 {
        x = point.x + tooltipWidth / 2 + padding
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

struct TooltipSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct RuneTooltipView: View {
    var rune: Rune
    let widthRatio = 0.55
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let enchant = rune.enchant {
                VStack{
                    Image(rune.enchant!.image)
                        .resizable()
                        .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                    Text(enchant.description)
                        .font(.custom("Trattatello", size: 0.05*screenWidth))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .frame(width: screenWidth*widthRatio)
                .runeBinderButtonStyle()
            }
            else if(rune.debuff == nil){
                Text("Basic \(String(rune.letter)) rune")
                    .font(.custom("Trattatello", size: 0.05*screenWidth))
                    .frame(width: screenWidth*widthRatio)
                    .runeBinderButtonStyle()
            }
            if(rune.debuff != nil){
                VStack{
                    Image(rune.debuff!.image)
                        .resizable()
                        .frame(width: 0.18*screenWidth, height: 0.18*screenWidth)
                    Text(rune.debuff!.text)
                        .font(.custom("Trattatello", size: 0.05*screenWidth))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(nil)
                }
                .frame(width: screenWidth*widthRatio)
                .runeBinderButtonStyle()
            }
        }
        .shadow(radius: 5)
        .overlay(
            GeometryReader { geo in
                Color.clear
                    .preference(key: TooltipSizePreferenceKey.self, value: geo.size)
            }
        )
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

struct CombatView: View {
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
            HStack(alignment: .bottom) {
                // Player on left
                PlayerView()
                    .padding(.leading, screenWidth*0.51)
                    .offset(y: screenHeight*0.09)
                Spacer()
                // Enemies on right
                EnemyListView()
                    .padding(.trailing, screenWidth*0.51)
                    .offset(y: screenHeight*0.09)
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

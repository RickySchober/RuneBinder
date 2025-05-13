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
    @Namespace private var runesNamespace //Used to animate between views
    var body: some View {
        VStack(spacing:0){
            CombatView()
                .frame(width: screenWidth, height: screenHeight*0.9-screenWidth*1.05)
                .background(.blue)
            RuneGrid(namespace: runesNamespace)
                .background(.yellow)
            SpellView(namespace: runesNamespace)
                .frame(width: screenWidth, height: screenWidth*0.20) //Reserve this space for view regardless of adjusted size
                .background(.green)
            Button(action:{
                viewModel.validSpell ? self.viewModel.castSpell() : print("your bad")
            }, label: {Text("Cast Spell")
                    .font(.system(size: 60.0))
            })
            .background(viewModel.validSpell ? Color.gray : Color.yellow )
            .frame(width: screenWidth, height: screenHeight*0.1, alignment: .center)
            .scaledToFill()
        }
        .edgesIgnoringSafeArea(.top)
        //.frame(width: screenWidth, height: screenHeight)
        .background(Color.red.opacity(0.3))
        //.animation(.easeOut)
    }
}


struct RuneView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var rune: Rune
    var namespace: Namespace.ID
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack{
                Image("Rune1")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.original)
                Rectangle()
                    .fill((rune.enchant==nil) ? Color.yellow : rune.enchant!.color)
                    .opacity(0.2)
                Text(String(rune.letter))
                    .font(Font.system(size:(CGFloat)(0.5*min(geometry.size.width,geometry.size.height))))
                    .multilineTextAlignment(.center)
            }
            .matchedGeometryEffect(id: rune.id, in: namespace)
            .onTapGesture{
                withAnimation(.easeInOut(duration: 0.2)){
                    viewModel.selectRune(rune: rune)
                }
            }
            // .onLongPressGesture(perform: viewModel.) provide description of rune effects on hold
        })
        .frame(minWidth: screenWidth*0.05, idealWidth: screenWidth*0.20, maxWidth: screenWidth*0.20,minHeight: screenWidth*0.05, idealHeight: screenWidth*0.20, maxHeight: screenWidth*0.20)
    }
}
struct EnemyView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var enemy: Enemy
    var body: some View{
        Image(enemy.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: screenWidth*0.18, height: screenWidth*0.18)
            .clipped()
            .onTapGesture{ viewModel.selectEnemy(enemy: enemy)
            }
            //.renderingMode(Image.TemplateRenderingMode.original)
    }
}
struct RuneGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
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
                VStack {
                    EnemyView(enemy: enemy)
                    Text("HP: \(enemy.currentHealth)/\(enemy.maxHealth)")
                        .font(.caption)
                        .foregroundColor(.white)
                    /*if let status = enemy.bleeds[0].dmg {
                        Text(status)
                            .font(.caption2)
                            .foregroundColor(.cyan)
                    }*/
                }
                .padding(0)
                .background((viewModel.target?.id == enemy.id ) ? Color.red.opacity(0.3) : Color.clear)
                .cornerRadius(10)
            }
        }
    }
}
struct PlayerInfoView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel

    var body: some View {
        VStack {
            Text("Player HP: \(viewModel.player.currentHealth)/\(viewModel.player.maxHealth)")
                .foregroundColor(.green)
            Text("Spell Power: \(viewModel.spellPower)")
                .foregroundColor(.purple)
            /*Text(viewModel.isPlayerTurn ? "Your Turn" : "Enemy Turn")
                .font(.headline)
                .foregroundColor(viewModel.isPlayerTurn ? .yellow : .orange)*/
        }
    }
}

struct CombatView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            // Player on the left
            PlayerInfoView()
                .frame(width: screenWidth * 0.3, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Spacer()

            // Enemies on the right
            EnemyListView()
        }
        .padding(0)
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RuneBinderViewModel())
    }
}

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
    @EnvironmentObject var viewModel: RuneBinderViewModel //Envirnment objects can be shared among all views

    var body: some View {
        VStack(spacing:0){
            CombatView()
                .frame(width: screenWidth, height: screenHeight*0.9-screenWidth*1.25)
                .background(.blue)
            RuneGrid()
                .background(.yellow)
            SpellView()
                .frame(width: screenWidth, height: screenWidth*0.24) //Reserve this space for view regardless of adjusted size
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
            .onTapGesture{ viewModel.selectRune(rune: rune)
            }
            // .onLongPressGesture(perform: viewModel.) provide description of rune effects on hold
        })
        .frame(minWidth: screenWidth*0.05, idealWidth: screenWidth*0.24, maxWidth: screenWidth*0.24,minHeight: screenWidth*0.05, idealHeight: screenWidth*0.24, maxHeight: screenWidth*0.24)
    }
}
struct EnemyView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var enemy: Enemy
    var body: some View{
        Image(enemy.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: screenHeight*0.1, height: screenHeight*0.1)
            .clipped()
            .onTapGesture{ viewModel.selectEnemy(enemy: enemy)
            }
            //.renderingMode(Image.TemplateRenderingMode.original)
    }
}
struct RuneGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        let columns = [
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0),
            GridItem(.flexible(),spacing: 0)
        ]
        LazyVGrid(columns: columns, spacing: 5 ){//Grid with 4 columns
            ForEach(self.viewModel.grid){ runes in
                if(!viewModel.spell.contains(runes)){
                    RuneView(rune: runes)
                        .aspectRatio(contentMode: .fit)

                }
                else{
                    Rectangle()
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: screenWidth*0.24, height: screenWidth*0.24)
                        .background(Rectangle().fill(Color.mint))
                }
            }
        }
        .frame(width: screenWidth, height: screenWidth)
    }
}
struct SpellView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        HStack(alignment: .top){
            ForEach(self.viewModel.spell, id: \.id){ runes in
                    RuneView(rune: runes)
                        .padding(-3)
            }
        }
        .frame(width: min(screenWidth,(screenWidth/4.0*(CGFloat)(viewModel.spell.count))), height: screenWidth*CGFloat(viewModel.spellRuneSize)) //adjust allocated width with spell length
    }
}

struct CombatView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        HStack{
            ForEach(viewModel.enemies){ enemy in
                EnemyView(enemy: enemy)
            }
            Text("Player Health: "+String(viewModel.player.currentHealth)+"/"+String(viewModel.player.maxHealth)+"\nSpell Power: "+String(viewModel.spellPower))
                .font(.body)
                .foregroundColor(Color.red)
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RuneBinderViewModel())
    }
}

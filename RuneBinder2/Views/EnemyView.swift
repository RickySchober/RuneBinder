//
//  EnemyView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/24/25.
//

import SwiftUI

struct EnemyView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State var lunge: CGFloat = 0
    @State var recoil: CGFloat = 0
    @State private var previousFloatingTexts: [FloatingTextData] = []
    var enemy: Enemy
    var healthRatio: CGFloat {
        CGFloat(enemy.currentHealth) / CGFloat(enemy.maxHealth)
    }
    var body: some View{
        VStack(spacing: 0){
            EnemyActionView(enemy: enemy)
            HealthBar(entity: enemy)
                .frame(width: screenWidth*0.18)
            DebuffGrid(entity: enemy)
            VStack{
                Spacer() //force enemy to bottom
                ZStack(){
                    Ellipse()
                        .fill(Color.black.opacity(0.3))
                        .blur(radius: 5)
                        .offset(y:screenWidth*0.13)
                        .frame(width: screenWidth*0.18, height: screenWidth*0.061)
                    Image(enemy.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture{
                            viewModel.selectEnemy(enemy: enemy)
                        }
                    StatusApplied(entity: enemy)
                }
            }
            .frame(width: screenWidth*0.18, height: screenWidth*0.27)
            .offset(x: lunge + recoil)
        }
        .overlay{
                ForEach(viewModel.floatingTexts){ text in
                    if(text.entityId == enemy.id){
                        AnimatedGIFView(name: "impact", loopCount: 1)
                            .frame(width: screenWidth*0.18, height: screenWidth*0.18)
                            .autoDisappear(after: 0.5)
                    }
                }
        }
        .onChange(of: viewModel.lungeTrigger) { newValue in
            if(viewModel.lunge == enemy.id){
                withAnimation(.easeOut(duration: 0.15)) {
                    lunge = -screenWidth*0.18
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        lunge = 0
                    }
                }
            }
        }
        .onChange(of: viewModel.floatingTexts) { newValue in
            // Detect new floating texts for this enemy
            let newForEnemy = newValue.filter { $0.entityId == enemy.id }
                .filter { newText in !previousFloatingTexts.contains(where: { $0.id == newText.id }) }

            if !newForEnemy.isEmpty {
                withAnimation(.easeOut(duration: 0.15)) {
                    recoil = screenWidth * 0.02
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeIn(duration: 0.25)) {
                        recoil = 0
                    }
                }
            }

            // Update for next comparison
            previousFloatingTexts = newValue
        }

        .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) { anchor in
            [enemy.id: anchor]
        }
        .transition(.asymmetric(insertion: .identity , removal: .opacity)) //animates insertion and deletion of view
    }
}

struct EnemyActionView: View{
    let enemy: Enemy
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State var echo: Int = 0
    var body: some View{
        if(enemy.chosenAction != nil){
            GeometryReader { geometry in
                let size = geometry.size
                BobbingView(amplitude: screenWidth*0.015, speed: 1.2) {
                    ZStack(){
                        if(enemy.chosenAction!.gaurd>0){
                            Image("ward")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth*0.09, height: screenWidth*0.09)
                                .echoEffect(
                                    trigger: echo,
                                    appearTrigger: false,
                                    scale: 3.0,
                                    opacity: 0.4,
                                    duration: 0.8,
                                    repeats: 3
                                )
                        }
                        else if(enemy.chosenAction!.debuffs.count>0){
                            Image("status")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth*0.09, height: screenWidth*0.09)
                                .echoEffect(
                                    trigger: echo,
                                    appearTrigger: false,
                                    scale: 3.0,
                                    opacity: 0.4,
                                    duration: 0.8,
                                    repeats: 3
                                )
                        }
                        if(enemy.chosenAction!.damage > 0){
                            Image("attack")
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth*0.09, height: screenWidth*0.09)
                                .echoEffect(
                                    trigger: echo,
                                    appearTrigger: false,
                                    scale: 3.0,
                                    opacity: 0.4,
                                    duration: 0.8,
                                    repeats: 3
                                )
                            Text("\(enemy.chosenAction!.damage)")
                                .foregroundColor(.white)
                                .bold()
                                .position(x: 0.9 * size.width, y: 0.85 * size.height)
                                .font(.system(size: 0.5 * min(size.width, size.height)))
                        }
                    }
                }
            }
            .onChange(of: viewModel.lungeTrigger) { newValue in
                if(viewModel.lunge == enemy.id){
                   echo += 1 // If enemy is attacking trigger animation on icon
                }
            }
            .frame(width: screenWidth*0.09, height: screenWidth*0.09)
        }
    }
}
struct BobbingView<Content: View>: View {
    let amplitude: CGFloat    // how far up/down it moves
    let speed: Double         // duration of one full cycle
    let content: () -> Content

    @State private var offset: CGFloat = 0

    var body: some View {
        content()
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: speed)
                        .repeatForever(autoreverses: true)
                ) {
                    offset = -amplitude
                }
            }
    }
}

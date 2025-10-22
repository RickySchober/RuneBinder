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
    var enemy: Enemy
    var healthRatio: CGFloat {
        CGFloat(enemy.currentHealth) / CGFloat(enemy.maxHealth)
    }
    var body: some View{
        VStack(spacing: 0){
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
                        .clipped()
                        .onTapGesture{ viewModel.selectEnemy(enemy: enemy)
                        }
                }
                .offset(x: lunge)
            }
            .frame(width: screenWidth*0.18, height: screenWidth*0.27)
        }
        .onChange(of: viewModel.lunge) { newValue in
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
       .overlay{
            ForEach(viewModel.floatingTexts){ text in
                if(text.entityId == enemy.id){
                    AnimatedGIFView(name: "impact", loopCount: 1)
                        .frame(width: screenWidth*0.18, height: screenWidth*0.18)
                }
            }
        }
        .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) { anchor in
            [enemy.id: anchor]
        }
        .transition(.asymmetric(insertion: .identity , removal: .opacity)) //animates insertion and deletion of view
    }
}
struct DebuffGrid: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var entity: Entity
    @State var scale: Double = 1.0
    var body: some View{
        ZStack{
            ForEach(entity.debuffs.indices, id: \.self) { index in
                let debuff = entity.debuffs[index]
                GeometryReader { geometry in
                    let size = geometry.size
                    ZStack(alignment: .topLeading) {
                        Image(debuff.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                        Text("\(debuff.value)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .position(x: 0.8 * size.width, y: 0.8 * size.height)
                            .font(.system(size: 0.2 * min(size.width, size.height)))
                    }
                }
                .scaleEffect(scale)
                .onChange(of: debuff.value){ _ in
                    withAnimation(.easeOut(duration: 0.15)) {
                        scale = 2.0                        }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            scale = 1.0
                        }
                    }
                }
                .onAppear(){
                    withAnimation(.easeOut(duration: 0.15)) {
                        scale = 2.0                        }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            scale = 1.0
                        }
                    }
                }
                .frame(width: screenWidth * 0.04, height: screenWidth * 0.04)
                .offset(x: CGFloat(index % 4) * screenWidth * 0.04 - screenWidth*0.05,
                        y: CGFloat(index / 4) * screenWidth * 0.04)
            }
        }
        .padding(1)
    }
}
struct HealthBar: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var entity: Entity
    var healthRatio: CGFloat {
        CGFloat(entity.currentHealth) / CGFloat(entity.maxHealth)
    }
    var wardRatio: CGFloat {
        min(CGFloat(entity.ward) / CGFloat(entity.maxHealth), 1.0)
    }
    var body: some View{
        if(entity.ward>0){
            ZStack(alignment: .leading) { //Block bar
                Rectangle()
                    .frame(width: screenWidth*0.13, height: screenHeight*0.0075)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(3)
                Rectangle()
                    .frame(width: screenWidth*0.13*min(1 ,wardRatio), height: screenHeight*0.0075) // 50 is total width
                    .foregroundColor(.blue)
                    .cornerRadius(3)
                
                Text("\(entity.ward)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frame(width: screenWidth*0.13, height: screenHeight*0.02)
                    .minimumScaleFactor(0.5)
                    .lineLimit(nil)
            }
            .animation(.linear(duration: 0.5), value: wardRatio)
            .padding(0)
        }
        ZStack(alignment: .leading) { //HP bar
            Rectangle()
                .frame(width: screenWidth*0.13, height: screenHeight*0.0075)
                .foregroundColor(.gray.opacity(0.3))
                .cornerRadius(3)
            Rectangle()
                .frame(width: max(0, screenWidth*0.13*healthRatio), height: screenHeight*0.0075) // 50 is total width
                .foregroundColor(.red)
                .cornerRadius(3)
            Text("\(entity.currentHealth)/\(entity.maxHealth)")
                .font(.caption2)
                .foregroundColor(.white)
                .frame(width: screenWidth*0.13, height: screenHeight*0.02)
                .minimumScaleFactor(0.5)
                .lineLimit(nil)
        }
        .padding(0)
        .animation(.linear(duration: 0.5), value: healthRatio)
    }
}

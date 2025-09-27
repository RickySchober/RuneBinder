//
//  EnemyView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/24/25.
//

import SwiftUI

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
            }
            .frame(width: screenWidth*0.18, height: screenWidth*0.27)
        }
        .transition(.asymmetric(insertion: .identity , removal: .opacity)) //animates insertion and deletion of view
    }
}

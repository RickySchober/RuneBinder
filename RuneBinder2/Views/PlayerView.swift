//
//  PlayerView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/24/25.
//

import SwiftUI


struct PlayerView: View {
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
            ZStack(){
                Ellipse()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: screenWidth*0.18, height: screenWidth*0.061)
                    .blur(radius: 5)
                    .offset(y:screenWidth*0.13)
                Image("hermit")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenWidth*0.18, height: screenWidth*0.27)
                    .clipped()
                
            }

        }
    }
}

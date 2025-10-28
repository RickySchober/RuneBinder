//
//  PlayerView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/24/25.
//

import SwiftUI


struct PlayerView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State var lunge: CGFloat = 0
    var player: Player
    var body: some View {
        VStack(spacing: 0) {
            HealthBar(entity: player)
            DebuffGrid(entity: player)
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
            }
            .idleAnimation(hoverAmplitude: 0.0, scaleAmplitude: 0.03, rotationAmplitude: -1, duration: 1.0)
            .offset(x: lunge)
        }
        .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) { anchor in
            [player.id: anchor]
        }
        .onChange(of: viewModel.lungeTrigger) { newValue in
            if(viewModel.lunge == player.id){
                withAnimation(.easeOut(duration: 0.15)) {
                    lunge = screenWidth*0.18
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        lunge = 0
                    }
                }
            }
        }
    }
}

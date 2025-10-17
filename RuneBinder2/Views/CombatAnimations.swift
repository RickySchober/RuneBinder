//
//  CombatAnimations.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 10/16/25.
//

import SwiftUI

struct FloatingTextView: View {
    let text: String
    let color: Color
    @State private var opacity = 1.0
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    var body: some View {
        Text(text)
            .font(.custom("CinzelDecorative-Regular", size: 32))
            .fontWeight(.bold)
            .foregroundColor(color)
            .shadow(radius: 4)
            .opacity(opacity)
            .offset(x: offsetX, y: offsetY)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    offsetY = -screenWidth*0.27
                    offsetX = CGFloat(Float.random(in: -Float(screenWidth)*0.1...Float(screenWidth)*0.1))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        offsetY = 0
                        offsetX *= 2
                    }
                }
            }
    }
}

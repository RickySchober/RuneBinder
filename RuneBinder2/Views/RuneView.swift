//
//  RuneView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/21/25.
//

import SwiftUI

struct RuneView: View{
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @State private var locked: Int = 0
    @State private var hoverWorkItem: DispatchWorkItem? = nil //Adds delay to turn drag gesture into a psuedo long press
    var rune: Rune
    var namespace: Namespace.ID
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack{
                Rectangle()
                    .fill((rune.enchant==nil) ? Color.brown : rune.enchant!.color)
                    .opacity(0.8)
                Image("Rune1")
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.original)
                    .frame(width: geometry.size.width*0.9, height: geometry.size.height*0.9)
                Rectangle()
                    .fill((rune.enchant==nil) ? Color.yellow : rune.enchant!.color)
                    .opacity(0.2)
                Text(String(rune.letter))
                    .font(Font.system(size:(CGFloat)(0.5*min(geometry.size.width,geometry.size.height))))
                    .multilineTextAlignment(.center)
                Text(String(rune.weaken == 0 ? rune.power : 0))
                    .foregroundColor(.white)
                    .position(x: 0.8*geometry.size.width, y: 0.8*geometry.size.height)
                    .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                    .padding([.bottom, .trailing], 1)
                if(rune.rot > 0){
                    Image("rot")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.rot)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                }
                if(rune.lock > 0){
                    Image("chain")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.lock)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                }
                if(rune.scorch > 0){
                    Image("fire")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.scorch)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                }
                if(rune.weaken > 0){
                    Image("weak")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.weaken)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                }
            }
            .matchedGeometryEffect(id: rune.id, in: namespace)
            .modifier(Shake(animatableData: CGFloat(locked)))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if hoverWorkItem == nil {
                            let workItem = DispatchWorkItem {
                                viewModel.hoverRune(rune: rune)
                            }
                            hoverWorkItem = workItem
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
                        }
                    }
                    .onEnded { _ in
                        hoverWorkItem?.cancel()
                        hoverWorkItem = nil
                        viewModel.hoverRune(rune: nil)
                    }
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        hoverWorkItem?.cancel()
                        hoverWorkItem = nil
                        if rune.lock != 0 {
                            SoundManager.shared.playSoundEffect(named: "click")
                            withAnimation {
                                locked += 1
                            }
                        } else {
                            SoundManager.shared.playSoundEffect(named: "click")
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectRune(rune: rune)
                            }
                        }
                    }
            )

        })
        .frame(minWidth: screenWidth*0.05, maxWidth: screenWidth*0.20,minHeight: screenWidth*0.05, maxHeight: screenWidth*0.20)
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = screenWidth*0.03
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


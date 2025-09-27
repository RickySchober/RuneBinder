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
                Text(String(rune.debuff?.type != .weak ? rune.power : 0))
                    .foregroundColor(.white)
                    .position(x: 0.8*geometry.size.width, y: 0.8*geometry.size.height)
                    .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                    .padding([.bottom, .trailing], 1)
                if(rune.debuff != nil){
                    Image(rune.debuff!.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.debuff!.value)")
                        .font(.caption2)
                        .foregroundColor(.black)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                }
     
               /* LinearGradient(colors: [.white.opacity(0.6), .clear],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .blendMode(.screen)*/
/*
                case .weak:
                    Color.blue.opacity(0.3)
                        .blendMode(.multiply)*/
/*
                RadialGradient(colors: [.black.opacity(0.6), .clear],
                               center: .center, startRadius: 0, endRadius: 60)
                    .blendMode(.multiply)*/
            }
        })
        .frame(minWidth: screenWidth*0.05, maxWidth: screenWidth*0.20,minHeight: screenWidth*0.05, maxHeight: screenWidth*0.20)
        .modifier(Shake(animatableData: CGFloat(locked)))
        .matchedGeometryEffect(id: rune.id, in: namespace) //Only gestures can be below matched geometry
        .gesture( //Must have tapgesture first or it doesn't animate?!?!
            TapGesture()
                .onEnded {
                    hoverWorkItem?.cancel()
                    hoverWorkItem = nil
                    if rune.debuff?.type == .lock  {
                        SoundManager.shared.playSoundEffect(named: "click")
                        withAnimation {
                            locked += 1
                        }
                    } else {
                        SoundManager.shared.playSoundEffect(named: "click")
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.selectRune(rune: rune)
                        }
                    }
                }
        )
        .simultaneousGesture(
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


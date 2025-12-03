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
    @State private var scale: Double = 1.0
    @State private var hoverWorkItem: DispatchWorkItem? = nil //Adds delay to turn drag gesture into a psuedo long press
    var rune: Rune
    var namespace: Namespace.ID
    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                hoverWorkItem?.cancel()
                hoverWorkItem = nil
                if rune.debuff?.archetype == .lock  {
                    SoundManager.shared.playSoundEffect(named: "click")
                    withAnimation { locked += 1 }
                } else {
                    SoundManager.shared.playSoundEffect(named: "click")
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.selectRune(rune: rune)
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
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
    }
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack{
                Rectangle()
                    .fill((rune.enchant==nil) ? Color.brown : rune.enchant!.color)
                    .opacity(0.2)
                if(rune.enchant != nil){
                    Image(rune.enchant!.image)
                        .resizable()
                        .renderingMode(Image.TemplateRenderingMode.original)
                        .frame(width: geometry.size.width*0.9, height: geometry.size.height*0.9)
                    if(rune.enchant!.upgraded){
                        Text("+")
                            .foregroundColor(.white)
                            .position(x: 0.8*geometry.size.width, y: 0.13*geometry.size.height)
                            .font(Font.system(size:(CGFloat)(0.3*min(geometry.size.width,geometry.size.height))))
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 3, y: 3)
                            .bold()                    }
                }
                Text(String(rune.letter))
                    .font(.custom("IM_FELL_English_Roman", size:(CGFloat)(0.55*min(geometry.size.width,geometry.size.height))))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 3, y: 3)
                    .foregroundColor(.white)
                    .bold()
                Text(String(rune.debuff?.archetype != .weak ? rune.power : 0))
                    .foregroundColor(.white)
                    .position(x: 0.8*geometry.size.width, y: 0.8*geometry.size.height)
                    .font(Font.system(size:(CGFloat)(0.3*min(geometry.size.width,geometry.size.height))))
                    .padding([.bottom], 3)
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 3, y: 3)
                    .bold()
                if(rune.debuff != nil){
                    Image(rune.debuff!.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .padding(0)
                        .frame(width: geometry.size.width*0.2, height: geometry.size.height*0.2)
                        .position(x: 0.15*geometry.size.width, y: 0.15*geometry.size.height)
                    Text("\(rune.debuff!.value)")
                        .foregroundColor(.white)
                        .position(x: 0.2*geometry.size.width, y: 0.2*geometry.size.height)
                        .font(Font.system(size:(CGFloat)(0.2*min(geometry.size.width,geometry.size.height))))
                        .padding([.bottom, .trailing], 1)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 3, y: 3)
                        .bold()
                }
            }
        })
        .overlay(
                TouchHoldView(minimumPressDuration: 0.6,
                              onTouchDown: { viewModel.hoverRune(rune: rune) },
                              onTouchUp: { viewModel.hoverRune(rune: nil) })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            )
        .runeTileStyle(shadowDepth: 0.09)
        .modifier(Shake(animatableData: CGFloat(locked)))
        .anchorPreference(key: RunePositionPreferenceKey.self, value: .center) { anchor in
            [rune.id: anchor]
        }
        .frame(minWidth: screenWidth*0.05, maxWidth: screenWidth*0.20,minHeight: screenWidth*0.05, maxHeight: screenWidth*0.20)
        .matchedGeometryEffect(id: rune.id, in: namespace, properties: .position)
        .gesture( //Must have tapgesture first or it doesn't animate?!?!
            TapGesture()
                .onEnded {
                    print("Tap over")
                    hoverWorkItem?.cancel()
                    hoverWorkItem = nil
                    if rune.debuff?.archetype == .lock  {
                        Task{
                            SoundManager.shared.playSoundEffect(named: "click")
                        }
                        withAnimation {
                            locked += 1
                        }
                    } else {
                        Task{
                            SoundManager.shared.playSoundEffect(named: "click")
                        }
                        withAnimation(.easeInOut(duration: 0.4)) {
                            viewModel.selectRune(rune: rune)
                        }
                    }
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

import UIKit
/* Because the draggesture breaks animation and swift has no other way to get touchUp gesture
   must use a UIKit view as helper for long presses that trigger a closure on touchUp.
 */
struct TouchHoldView: UIViewRepresentable {
    var minimumPressDuration: TimeInterval = 0.6
    var onTouchDown: () -> Void
    var onTouchUp: () -> Void

    func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        v.backgroundColor = .clear
        // Use UILongPressGestureRecognizer to get began/ended states
        let gr = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handle(_:)))
        gr.minimumPressDuration = minimumPressDuration
        gr.cancelsTouchesInView = false
        v.addGestureRecognizer(gr)
        // Also detect immediate touches (touchesBegan/Ended) via a subclass if you want immediate down:
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(onDown: onTouchDown, onUp: onTouchUp)
    }

    class Coordinator: NSObject {
        let onDown: () -> Void
        let onUp: () -> Void

        init(onDown: @escaping () -> Void, onUp: @escaping () -> Void) {
            self.onDown = onDown
            self.onUp = onUp
        }

        @objc func handle(_ gr: UILongPressGestureRecognizer) {
            switch gr.state {
            case .began:
                onDown()
            case .ended, .cancelled, .failed:
                onUp()
            default:
                break
            }
        }
    }
}

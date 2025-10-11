//
//  MainMenuView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 8/27/23.
//

import SwiftUI

struct MainMenuView: View {
    @State private var isPresentingStart = false
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        
        Text("Runebinder")
            .font(.system(size: 60.0))
            .runeBinderButtonStyle()
        Spacer()
        Button(action:{
        }, label: {Text("Continue")
                .font(.system(size: 60.0))
                .onTapGesture {
                    viewRouter.currentScreen = viewModel.loadSave()
                    SoundManager.shared.playBackgroundMusic(named: "soundtrack")
                }
        })
        .padding(10)
        .runeBinderButtonStyle()
        Button(action:{
        }, label: {Text("New Game")
                .font(.system(size: 60.0))
                .onTapGesture {
                    SoundManager.shared.playBackgroundMusic(named: "soundtrack")
                    viewRouter.currentScreen = .map
                }
        })
        .padding(10)
        .runeBinderButtonStyle()
        Button(action:{
        }, label: {Text("Back")
                .font(.system(size: 60.0))
        })
        .padding(10)
        .runeBinderButtonStyle()
    }
}

struct RuneBinderButtonStyle: ViewModifier {
    var cornerColor: Color = Color(red: 0.5, green: 0.35, blue: 0.2)
    var backgroundColor: Color = Color(red: 0.96, green: 0.9, blue: 0.75)
    var borderColor: Color = Color(red: 0.4, green: 0.25, blue: 0.1)
    var pressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .font(.custom("CinzelDecorative-Regular", size: 20))
            .foregroundColor(cornerColor)
            .background(
                ZStack {
                    Rectangle()
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
                    Rectangle()
                        .stroke(borderColor, lineWidth: 6)
                        .overlay(
                            VStack {
                                HStack {
                                    cornerDecoration()
                                    Spacer()
                                    cornerDecoration()
                                        .rotationEffect(.degrees(90))
                                }
                                Spacer()
                                HStack {
                                    cornerDecoration()
                                        .rotationEffect(.degrees(270))
                                    Spacer()
                                    cornerDecoration()
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            .padding(6)
                        )
                    Rectangle()
                        .stroke(cornerColor, lineWidth: 4)
                    Rectangle()
                        .stroke(backgroundColor, lineWidth: 2)
                }
            )
            .scaleEffect(pressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
    }
    
    // Helper corner decoration (pixel-style corner)
    private func cornerDecoration() -> some View {
        VStack(spacing: 1) {
            Rectangle()
                .fill(cornerColor)
                .frame(width: 4, height: 2)
            Rectangle()
                .fill(cornerColor)
                .frame(width: 2, height: 4)
        }
    }
}

extension View {
    func runeBinderButtonStyle(pressed: Bool = false) -> some View {
        self.modifier(RuneBinderButtonStyle(pressed: pressed))
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

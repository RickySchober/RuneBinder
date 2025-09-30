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
    var body: some View {
        Button(action:{
            isPresentingStart = true
        }, label: {Text("Start")
                .font(.system(size: 60.0))
        })
        .fullScreenCover(isPresented: $isPresentingStart) {
                    StartView(isSheetPresented: $isPresentingStart)
        }
        
    }
}

struct StartView: View{
    @Binding var isSheetPresented: Bool
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel //Environment objects can be shared among all views
    var body: some View {
        Button(action:{
        }, label: {Text("Continue")
                .font(.system(size: 60.0))
                .onTapGesture {
                    viewModel.loadSave()
                    SoundManager.shared.playBackgroundMusic(named: "soundtrack")
                    viewRouter.currentScreen = .map
                }
        })
        Button(action:{
        }, label: {Text("New Game")
                .font(.system(size: 60.0))
                .onTapGesture {
                    SoundManager.shared.playBackgroundMusic(named: "soundtrack")
                    viewRouter.currentScreen = .map
                }
        })
        Button(action:{
            isSheetPresented.toggle()
        }, label: {Text("Back")
                .font(.system(size: 60.0))
        })
    }
}
struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

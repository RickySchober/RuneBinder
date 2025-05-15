//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 5/2/23.
//

import SwiftUI

enum GameScreen {
    case mainMenu
    case levelSelect
    case combat
}

class ViewRouter: ObservableObject {
    @Published var currentScreen: GameScreen = .mainMenu
}

@main
struct RuneBinder2App: App {
    @StateObject var viewModel = RuneBinderViewModel()
    @StateObject var viewRouter = ViewRouter()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewRouter)
                .environmentObject(viewModel)
        }
    }
}

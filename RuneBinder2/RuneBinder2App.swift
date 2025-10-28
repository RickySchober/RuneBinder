//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 5/2/23.
//

import SwiftUI

enum GameScreen: String, Codable {
    case mainMenu, map, event, combat, shop, rest, settings
}

class ViewRouter: ObservableObject {
    @Published var currentScreen: GameScreen = .mainMenu
}


@main
struct RuneBinder2App: App {
    @StateObject private var viewModel = RuneBinderViewModel()
    @StateObject private var accountManager = AccountManager()
    @StateObject private var viewRouter = ViewRouter()
    init(){
        SoundManager.shared.preloadAll(from: "Sound Effects")
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(accountManager)
                .environmentObject(viewRouter)
                .environmentObject(viewModel)
        }
    }
}

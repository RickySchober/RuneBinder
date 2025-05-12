//
//  RuneBinderApp.swift
//  RuneBinder
//
//  Created by Ricky Schober on 5/2/23.
//

import SwiftUI

@main
struct RuneBinder2App: App {
    @StateObject var game = RuneBinderViewModel()
    var body: some Scene {
        WindowGroup {
            //MainMenuView()
            ContentView().environmentObject(game) //must pass viewmodel as environment object
        }
    }
}


import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        switch viewRouter.currentScreen {
        case .mainMenu:
            MainMenuView()
        case .levelSelect:
            ContentView()
        case .combat:
            ContentView() // your current combat screen
        }
    }
}

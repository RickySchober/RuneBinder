
import SwiftUI

struct RootView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel
    var body: some View {
        switch viewRouter.currentScreen {
        case .mainMenu:
            MainMenuView()
        case .map:
            MapView(map: viewModel.map)
        case .combat:
            ContentView() // your current combat screen
        case .event:
            EventView()
        case .shop:
            ShopView()
        case .settings:
            SettingsView()
        }
    }
}

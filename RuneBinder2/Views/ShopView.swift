//
//  ShopView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/19/25.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel //Environment objects can be shared among all views
    @EnvironmentObject var viewRouter: ViewRouter
    var body: some View {
        Text("Continue")
            .onTapGesture {
                viewRouter.currentScreen = .map
            }
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
    }
}

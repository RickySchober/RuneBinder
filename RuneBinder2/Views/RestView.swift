//
//  RestView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 9/30/25.
//

import SwiftUI

struct RestView: View {
    @EnvironmentObject var viewModel: RuneBinderViewModel //Environment objects can be shared among all views
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var upgradeViewer: Bool = false
    @State private var removeViewer: Bool = false
    var body: some View {
        ZStack(){
            VStack(spacing:0){
                Image("abandoned_library_bg1")
                    .frame(width: screenWidth, height: screenHeight*0.9-screenWidth*1.0)
                HStack(){
                    Button(action: {if(!viewModel.encounterOver){viewModel.rest()} }) {
                        VStack(spacing: 8) {
                            Text("Rest: Heal 1/3 of your health")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!viewModel.encounterOver ? Color.blue: Color.gray)
                                .shadow(radius: 4)
                        )
                    }
                    Button(action: { if(!viewModel.encounterOver) {upgradeViewer = true} }) {
                        VStack(spacing: 8) {
                            Text("Study: Upgrade an enchantment")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!viewModel.encounterOver ? Color.blue: Color.gray)
                                .shadow(radius: 4)
                        )
                    }
                }
                HStack(){
                    Button(action: { if(!viewModel.encounterOver) {removeViewer = true} }) {
                        VStack(spacing: 8) {
                            Text("Clean: Remove and enchantment")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(!viewModel.encounterOver ? Color.blue: Color.gray)
                                .shadow(radius: 4)
                        )
                    }
                    Button(action: {
                        viewModel.saveGame(node: nil)
                        viewRouter.currentScreen = .map
                    }) {
                        VStack(spacing: 8) {
                            Text("Leave")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .shadow(radius: 4)
                        )
                    }
                }
            }
            EnchantmentGridView(enchantments: viewModel.spellBook,
                                onTap: { enchant in
                                    upgradeViewer = false
                                    viewModel.upgradeEnchant(enchant: enchant)},
                                filter: { $0.upgraded == false })
            .offset(y: upgradeViewer ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: upgradeViewer)
            .onTapGesture { //Close all popups on tap
                upgradeViewer = false
            }
            EnchantmentGridView(enchantments: viewModel.spellBook,
                                onTap: { enchant in
                                    removeViewer = false
                                    viewModel.removeEnchant(enchant: enchant)})
            .offset(y: removeViewer ? 0 : UIScreen.main.bounds.height)
            .animation(.easeOut(duration: 0.5), value: removeViewer)
            .onTapGesture { //Close all popups on tap
                removeViewer = false
            }
        }
    }
}


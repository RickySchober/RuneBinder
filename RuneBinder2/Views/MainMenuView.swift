//
//  MainMenuView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 8/27/23.
//

import SwiftUI

struct MainMenuView: View {
    @State private var isCharSelect = false
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: RuneBinderViewModel
    @EnvironmentObject var accountManager: AccountManager
    var body: some View {
        if(!isCharSelect){
            Text("Runebinder")
                .font(.system(size: 60.0))
                .runeBinderButtonStyle()
            Spacer()
            Button(action:{
            }, label: {Text("Continue")
                    .font(.system(size: 60.0))
                    .onTapGesture {
                        /*for family in UIFont.familyNames {
                            for name in UIFont.fontNames(forFamilyName: family) {
                                print(name)
                            }
                        }*/
                        viewRouter.currentScreen = viewModel.loadSave()
                        SoundManager.shared.playBackgroundMusic(named: "soundtrack.nosync")
                    }
            })
            .padding(10)
            .runeBinderButtonStyle()
            Button(action:{
            }, label: {Text("New Game")
                    .font(.system(size: 60.0))
                    .onTapGesture {
                        isCharSelect = true
                    }
            })
            .padding(10)
            .runeBinderButtonStyle()
        }
        else{
            ForEach(accountManager.account.unlockedCharacters){ char in
                Button(action:{
                }, label: {Text(char.id)
                        .font(.system(size: 60.0))
                        .onTapGesture {
                            viewModel.selectCharacter(character: char)
                            viewRouter.currentScreen = .map
                            SoundManager.shared.playBackgroundMusic(named: "soundtrack")
                        }
                })
                .padding(10)
                .runeBinderButtonStyle()
            }
            Button(action:{
            }, label: {Text("Back")
                    .font(.system(size: 60.0))
                    .onTapGesture {
                        isCharSelect = false
                    }
            })
            .padding(10)
            .runeBinderButtonStyle()
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

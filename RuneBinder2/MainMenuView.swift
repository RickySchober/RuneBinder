//
//  MainMenuView.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 8/27/23.
//

import SwiftUI

struct MainMenuView: View {
    @State private var isPresentingStart = false
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
    var body: some View {
        Button(action:{
        }, label: {Text("Continue")
                .font(.system(size: 60.0))
        })
        NavigationLink("New Game",destination: ContentView())
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

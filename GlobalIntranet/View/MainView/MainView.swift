//
//  MainView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 30/12/2022.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        // Tab view with resent post's and profile tabs
        TabView {
            Text("Resent Post's")
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
        // Changing tab lable tint to black
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

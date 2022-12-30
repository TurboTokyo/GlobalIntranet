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
            
            Text("Provile View")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  GlobalIntranetApp.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 22/12/2022.
//

import SwiftUI
import Firebase

@main
struct GlobalIntranetApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

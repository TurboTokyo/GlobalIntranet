//
//  ContentView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 22/12/2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        // Redirecting User based on log status
        if logStatus {
            Text("Main view")
        } else {
            LoginView()
        }
    }
}


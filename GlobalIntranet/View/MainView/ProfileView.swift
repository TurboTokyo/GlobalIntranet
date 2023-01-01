//
//  ProfileView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 31/12/2022.
//

import SwiftUI

struct ProfileView: View {
    // The User's profile data
    @State var userProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Logout
                        Button("Logout") {
                            
                        }
                        
                        // Delete account
                        Button("Delete Account", role: .destructive) {
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
    }
}

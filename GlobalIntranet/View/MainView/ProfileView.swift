//
//  ProfileView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 31/12/2022.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    // The User's profile data
    @State private var userProfile: User?
    @AppStorage("log_status") var logStatus: Bool = false
    
    // View properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                if let userProfile {
                    Text(userProfile.username)
                }
            }
            .refreshable {
                // Refresh user data
                userProfile = nil
                await fetchUserData()
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Logout
                        Button("Logout", action: logOutUser)
                        
                        // Delete account
                        Button("Delete Account", role: .destructive, action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(.black)
                            .scaleEffect(0.8)
                    }
                }
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {}
        .task {
            // This modifier is like onAppear
            // so fetching for the first time only
            if userProfile != nil {return}
            
            // Initial fetch
            await fetchUserData()
        }
    }
    
    // Fetching User data
    func fetchUserData() async {
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else{return}
        await MainActor.run {
            userProfile = user
        }
    }
    
    // Logging User out
    func logOutUser() {
        try? Auth.auth().signOut()
        logStatus = false
    }
    
    // Deleting User entire account
    func deleteAccount() {
        isLoading = true
        
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                
                // First stage: Deleting profile picture from storage
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                try await reference.delete()
                
                // Second stage: Deleting Firestore User document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                
                // Third stage: Deleting auth account and setting log status to false
                try await Auth.auth().currentUser?.delete()
                logStatus = false
            } catch {
                await setError(error)
            }
        }
    }
    
    // Setting error
    func setError(_ error: Error) async {
        // UI must be fun on main thread
        await MainActor.run {
            isLoading = false
            
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
}

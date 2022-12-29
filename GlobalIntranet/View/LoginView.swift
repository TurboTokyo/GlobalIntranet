//
//  LoginView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 24/12/2022.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    
    // User details
    @State var emailID: String = ""
    @State var password: String = ""
    
    // View properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    // User defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12){
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action: loginUser) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            
            // Registration Button
            HStack {
                Text("Don't have an account ?")
                    .foregroundColor(.gray)
                
                Button("Register Now") {
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .vAlign(.bottom)
            .font(.callout)
        }
        .vAlign(.top)
        .padding(15)
        .overlay {
            LoadingView(show: $isLoading)
        }
        
        // Registration View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegistrationView()
        }
        
        // Displaying alert
        .alert(errorMessage, isPresented: $showError, actions: {
            
        })
    }
    
    func loginUser() {
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                // With the help of Swift concurrency auth can be done with single line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    // If User was found then fetching user data from Firestore
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        
        // UI updating must be run on main thread
        await MainActor.run {
            // Setting User defaults data and changing app's auth status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        }
    }
    
    func resetPassword() {
        Task {
            do {
                
                // With the help of Swift concurrency auth can be done with single line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link sent")
            } catch {
                await setError(error)
            }
        }
    }
    
    // Displaying errors VIA alert
    func setError(_ error: Error) async {
        
        // UI mast be updated on main thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

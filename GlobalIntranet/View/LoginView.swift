//
//  LoginView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 24/12/2022.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    // User details
    @State var emailID: String = ""
    @State var password: String = ""
    
    // View properties
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
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
        
        // Registration View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegistrationView()
        }
        
        // Displaying alert
        .alert(errorMessage, isPresented: $showError, actions: {
            
        })
    }
    
    func loginUser() {
        Task {
            do {
                // With the help of Swift concurrency auth can be done with single line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User found")
            } catch {
                await setError(error)
            }
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
        })
    }
}

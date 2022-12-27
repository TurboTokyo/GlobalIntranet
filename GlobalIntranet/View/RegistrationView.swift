//
//  RegistrationView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 27/12/2022.
//

import SwiftUI

struct RegistrationView: View {
    @State var username: String = ""
    @State var emailID: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack(spacing: 10){
            Text("Lets Sign you in")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Welcome Back, \nYou have been missed")
                .font(.title3)
                .hAlign(.leading)
            
            VStack(spacing: 12){
                TextField("Username", text: $username)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top, 25)
                
                TextField("Email", text: $emailID)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                SecureField("Password", text: $password)
                    .textContentType(.emailAddress)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?", action: {})
                    .font(.callout)
                    .fontWeight(.medium) // That wasn't an issue feature works from iOS 16.0, so I had to update Xcode
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button {
                    
                } label: {
                    Text("Sign up")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top, 10)
            }
            
            // Registration Button
            
            HStack {
                Text("Already have an account ?")
                    .foregroundColor(.gray)
                
                Button("Login Now") {
                    
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .vAlign(.bottom)
            .font(.callout)
        }
        .vAlign(.top)
        .padding(15)
    }
}

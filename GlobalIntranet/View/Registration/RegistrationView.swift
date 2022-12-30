//
//  RegistrationView.swift
//  GlobalIntranet
//
//  Created by Teuer Stein on 27/12/2022.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct RegistrationView: View {
    
    // User details
    @State var username: String = ""
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
    // View properties
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
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
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("What's up, User ?")
                .font(.title3)
                .hAlign(.leading)
            
            // For smaller size optimization
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            // Login Button
            HStack {
                Text("Already have an account ?")
                    .foregroundColor(.gray)
                
                Button("Login Now") {
                    dismiss()
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
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            
            // Extracting UIImage from PhotoItem
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else { return }
                        
                        // UI ust be updated on main thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                    } catch {
                        
                    }
                }
            }
        }
        // Displaying alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing: 12){
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            TextField("Username", text: $username)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You", text: $userBio, axis: .vertical)
                .frame(minHeight: 100, alignment: .top)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)", text: $userBioLink)
                .textContentType(.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            Button("Reset password?", action: {})
                .font(.callout)
                .fontWeight(.medium)
                .tint(.black)
                .hAlign(.trailing)
            
            Button(action: registerUser) {
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(
                username == "" ||
                userBio == "" ||
                emailID == "" ||
                password == "" ||
                userProfilePicData == nil
            )
            .padding(.top, 10)
        }
    }
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        
        Task {
            do {
                // First stage: creating Firebase account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                
                // Second stage: uploading profile picture into Firebase storage
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userProfilePicData else{return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                
                // Third stage: downloading photo URL
                let downloadURL = try await storageRef.downloadURL()
                
                // Fourth stage: creating a User Firestore object
                let user = User(username: username, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL)
                
                // Fifth stage: saving user doc into Firestore database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: {
                    error in
                    if error == nil {
                        // Print saved successfully
                        print("Saved successfully")
                        
                        userNameStored = username
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
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

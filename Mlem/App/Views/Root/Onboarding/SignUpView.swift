//
//  SignUpView.swift
//  Mlem
//
//  Created by Sjmarf on 05/09/2024.
//

import SwiftUI

struct SignUpView: View {
    @Environment(Palette.self) var palette
    
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var applicationQuestion: String = ""
    @State var showNsfw: Bool = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: Icons.warning)
                        .font(.title2)
                        .imageScale(.large)
                    Text("To join this instance, you need to create an application and wait to be accepted.")
                }
                .foregroundStyle(palette.caution)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(palette.caution, lineWidth: 3)
                        .background(palette.caution.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                )
            }
            
            Section("Username") {
                TextField("Username", text: $username, prompt: Text("JohnDoe"))
            } footer: {
                Text("Choose wisely - you **cannot** change this later.")
            }
            Section("Email") {
                TextField(
                    "Email",
                    text: $email,
                    prompt: Text(String(localized: "johndoe@example.com")) // Avoids this being rendered as a link
                )
            }
            
            Section("Password") {
                SecureField("Password", text: $password)
                SecureField("Confirm Password", text: $confirmPassword)
            }
            
            Section {
                TextField("Your Answer...", text: $applicationQuestion, axis: .vertical)
                    .lineLimit(8, reservesSpace: true)
            }
            
            Section {
                Toggle("Show NSFW Content", isOn: $showNsfw)
            }
        }
    }
}

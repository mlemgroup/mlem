//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-03.
//

import SwiftUI

struct ProfileSettingsView: View {
    let session: UserSession
    @State var displayName: String = ""
    
    @State var bioTextView: UITextView = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 6 + 20
    }
    
    var body: some View {
        Form {
            Section("Display Name") {
                TextField("Display Name", text: $displayName, prompt: Text(session.account.name))
            } footer: {
                Text("The name that is displayed on your profile. This is not the same as your username, which cannot be changed.")
            }
            Section("Biography") {
                MarkdownTextEditor(
                    onChange: { _ in
                    },
                    prompt: "Write a bit about yourself...",
                    textView: bioTextView,
                    insets: .init(),
//                    insets: .init(
//                        top: Constants.main.standardSpacing,
//                        left: Constants.main.standardSpacing,
//                        bottom: Constants.main.standardSpacing,
//                        right: Constants.main.standardSpacing
//                    ),
                    firstResponder: false,
                    content: {
                        MarkdownEditorToolbarView(
                            textView: bioTextView,
                            uploadHistory: uploadHistory,
                            imageUploadApi: session.api
                        )
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .listRowInsets(.init(
                    top: Constants.main.standardSpacing,
                    leading: Constants.main.standardSpacing,
                    bottom: Constants.main.standardSpacing,
                    trailing: Constants.main.standardSpacing
                ))
            }
        }
        .navigationTitle("My Profile")
    }
}

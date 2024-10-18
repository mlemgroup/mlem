//
//  ProfileSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-18.
//

import SwiftUI

struct ProfileSettingsView: View {
    @State var displayName: String = ""
    
    @State var descriptionTextView: UITextView = .init()

    @State var uploadHistory: ImageUploadHistoryManager = .init()
    
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 24
    }
    
    init() {
        guard let session = AppState.main.firstSession as? UserSession else {
            assertionFailure()
            return
        }
        guard let person = session.person else { return }
        _displayName = .init(wrappedValue: person.displayName)
        descriptionTextView.text = person.description
    }
    
    var body: some View {
        Form {
            Section("Display Name") {
                TextField("Display Name", text: $displayName, prompt: Text(AppState.main.firstAccount.name))
            }
            Section("Bio") {
                MarkdownTextEditor(
                    onChange: { _ in
                        
                    },
                    prompt: "Write a bit about yourself...",
                    textView: descriptionTextView,
                    includeInsets: false,
                    firstResponder: false,
                    content: {
                        MarkdownEditorToolbarView(
                            textView: descriptionTextView,
                            uploadHistory: uploadHistory,
                            imageUploadApi: AppState.main.firstApi
                        )
                    }
                )
                .lineLimit(5, reservesSpace: true)
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .listRowInsets(.init(top: 8, leading: 12, bottom: 0, trailing: 12))
            }
        }
        .navigationTitle("My Profile")
        .scrollDismissesKeyboard(.interactively)
    }
}

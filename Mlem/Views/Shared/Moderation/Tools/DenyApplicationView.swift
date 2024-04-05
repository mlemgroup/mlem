//
//  DenyApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Dependencies
import Foundation
import SwiftUI

struct DenyApplicationView: View {
    @Dependency(\.notifier) var notifier
    
    @Environment(\.dismiss) var dismiss
    
    let application: RegistrationApplicationModel
    
    @State var text: String = ""
    @State var isWaiting: Bool = false
    @FocusState var textFieldFocused: Bool
    
    var body: some View {
        content
            .onAppear {
                textFieldFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        submit()
                    } label: {
                        Image(systemName: Icons.send)
                    }
                    .disabled(text.isEmpty)
                }
            }
            .allowsHitTesting(!isWaiting)
            .opacity(isWaiting ? 0.5 : 1)
            .interactiveDismissDisabled(isWaiting)
    }
    
    var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                TextField("Denial reason", text: $text, axis: .vertical)
                    .padding(.horizontal, AppConstants.standardSpacing)
                    .focused($textFieldFocused)
                
                Divider()
                
                InboxRegistrationApplicationBodyView(application: application, showMenu: false)
            }
        }
    }
    
    func submit() {
        isWaiting = true
        Task {
            let success = await application.deny(reason: text)
            if success {
                await MainActor.run {
                    dismiss()
                }
                await notifier.add(.success("Denied Application"))
            } else {
                isWaiting = false
            }
        }
    }
}

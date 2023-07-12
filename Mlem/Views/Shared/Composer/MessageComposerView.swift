//
//  MessageComposerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation
import SwiftUI

struct MessageComposerView: View {
    // MARK: Environment
    @EnvironmentObject var appState: AppState
    
    // MARK: Parameters
    let recipient: APIPerson
    
    // MARK: State and other
    @Environment(\.dismiss) var dismiss
    
    @State var messageBody: String = ""
    @State var isSubmitting: Bool = false
    @State var sendingFailed: Bool = false
    private var isReadyToSend: Bool { !messageBody.trimmed.isEmpty }
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 15) {
                    
                    // Recipient
                    UserProfileLabel(user: recipient, serverInstanceLocation: .bottom, overrideShowAvatar: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Post Text
                    TextField("What do you want to say?",
                              text: $messageBody,
                              axis: .vertical)
                    .accessibilityLabel("Message Body")
                    Spacer()
                }
                .padding()
                
                // Loading Indicator
                if isSubmitting {
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Sending Message")
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
                }
            }

            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Submit Button
                    Button {
                        Task(priority: .userInitiated) {
                            await sendMessage()
                        }
                    } label: {
                        Image(systemName: "paperplane")
                    }.disabled(isSubmitting || !isReadyToSend)
                }
            }
            .alert("Failed to send", isPresented: $sendingFailed) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Something went wrong. Please try again.")
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func sendMessage() async {
        do {
            isSubmitting = true
            
            try await sendPrivateMessage(
                content: messageBody,
                recipient: recipient,
                account: appState.currentActiveAccount,
                appState: appState
            )
            
            print("Post Successful")
            
            dismiss()
            
        } catch {
            appState.contextualError = .init(underlyingError: error)
            isSubmitting = false
        }
    }
    
}

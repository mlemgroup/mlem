//
//  InboxCommentComposerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Foundation
import SwiftUI

struct GeneralCommentComposerView: View {
  
    let replyTo: any ReplyTo

    @Environment(\.dismiss) var dismiss

    @State var replybody: String = ""
    @State var isSubmitting: Bool = false
    @State var errorOccurred: Bool = false

    private var isReadyToReply: Bool {
        return replybody.trimmed.isNotEmpty
    }
    
    func uploadImage() {
        print("Uploading")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(spacing: 15) {
                        
                        // Post Text
                        TextField("What do you want to say?",
                                  text: $replybody,
                                  axis: .vertical)
                        .accessibilityLabel("Reply Body")
                        .padding()
                        
                        Spacer()

                        replyTo.embeddedView()
                    }
                    
                    // Loading Indicator
                    if isSubmitting {
                        ZStack {
                            Color.gray.opacity(0.3)
                            ProgressView()
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Submitting Reply")
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(false)
                    }
                }
                
                .navigationTitle("New Comment")
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
                                defer { isSubmitting = false }
                                do {
                                    isSubmitting = true
                                    try await replyTo.sendReply(commentContents: replybody)
                                    dismiss()
                                } catch {
                                    errorOccurred = true
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane")
                        }.disabled(isSubmitting || !isReadyToReply)
                    }
                }
                .alert("Failed to Send", isPresented: $errorOccurred) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Something went wrong!")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

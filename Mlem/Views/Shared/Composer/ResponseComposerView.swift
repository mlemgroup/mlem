//
//  InboxCommentComposerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Dependencies
import Foundation
import SwiftUI

struct ResponseComposerView: View {
    
    @Dependency(\.errorHandler) var errorHandler
    
    let respondable: any Respondable
    
    init(concreteRespondable: ConcreteRespondable) {
        self.respondable = concreteRespondable.respondable // don't need the wrapper
    }

    @Environment(\.dismiss) var dismiss

    @State var replybody: String = ""
    @State var isSubmitting: Bool = false

    private var isReadyToReply: Bool {
        return replybody.trimmed.isNotEmpty
    }
    
    func uploadImage() {
        if respondable.canUpload {
            print("Uploading")
        } else {
            print("Uploading disabled for this sort of response")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppConstants.postAndCommentSpacing) {
                    
                    // Post Text
                    TextField("What do you want to say?",
                              text: $replybody,
                              axis: .vertical)
                    .accessibilityLabel("Response Body")
                    .padding(AppConstants.postAndCommentSpacing)
                    
                    Divider()
                    
                    respondable.embeddedView()
                }
            }
            .overlay {
                // Loading Indicator
                if isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Submitting Resposne")
                        .edgesIgnoringSafeArea(.all)
                        .allowsHitTesting(false)
                }
            }
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
                                try await respondable.sendResponse(responseContents: replybody)
                                dismiss()
                            } catch {
                                errorHandler.handle(
                                    .init(
                                        title: "Failed to Send",
                                        message: "Something went wrong!",
                                        underlyingError: error
                                    )
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane")
                    }.disabled(isSubmitting || !isReadyToReply)
                }
            }
            .navigationTitle(respondable.modalName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

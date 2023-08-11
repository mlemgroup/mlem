//
//  EditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Dependencies
import Foundation
import SwiftUI

struct ResponseEditorView: View {
    
    private enum Field: Hashable {
        case editorBody
    }
    
    @Dependency(\.errorHandler) var errorHandler
    
    let editorModel: any ResponseEditorModel
    
    init(concreteEditorModel: ConcreteEditorModel) {
        self.editorModel = concreteEditorModel.editorModel // don't need the wrapper
        self._editorBody = State(initialValue: concreteEditorModel.editorModel.prefillContents ?? "")
    }

    @Environment(\.dismiss) var dismiss

    @State var editorBody: String
    @State var isSubmitting: Bool = false
    
    @FocusState private var focusedField: Field?

    private var isReadyToReply: Bool {
        return editorBody.trimmed.isNotEmpty
    }
    
    func uploadImage() {
        if editorModel.canUpload {
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
                              text: $editorBody,
                              axis: .vertical)
                    .accessibilityLabel("Response Body")
                    .padding(AppConstants.postAndCommentSpacing)
                    .focused($focusedField, equals: .editorBody)
                    .onAppear {
                        focusedField = .editorBody
                    }
                    
                    Divider()
                    
                    editorModel.embeddedView()
                }
                .padding(.bottom, AppConstants.editorOverscroll)
            }
            .scrollDismissesKeyboard(.automatic)
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
                            await submit()
                        }
                    } label: {
                        Image(systemName: "paperplane")
                    }.disabled(isSubmitting || !isReadyToReply)
                }
            }
            .navigationBarColor()
            .navigationTitle(editorModel.modalName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @MainActor
    private func submit() async {
        defer { isSubmitting = false }
        do {
            isSubmitting = true
            try await editorModel.sendResponse(responseContents: editorBody)
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
}

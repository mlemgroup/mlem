//
//  ResponseEditorView.swift
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
    @Dependency(\.siteInformation) var siteInformation
    
    let editorModel: any ResponseEditorModel
    
    init(concreteEditorModel: ConcreteEditorModel) {
        self.editorModel = concreteEditorModel.editorModel // don't need the wrapper
        self._editorBody = State(initialValue: concreteEditorModel.editorModel.prefillContents ?? "")
    }

    @Environment(\.dismiss) var dismiss

    @State var editorBody: String
    @State var isSubmitting: Bool = false
    
    @State var slurMatch: String?
    
    @FocusState private var focusedField: Field?

    private var isReadyToReply: Bool {
        editorBody.trimmed.isNotEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.postAndCommentSpacing) {
                // Post Text
                TextField(
                    "What do you want to say?",
                    text: $editorBody,
                    axis: .vertical
                )
                .lineLimit(AppConstants.textFieldVariableLineLimit)
                .accessibilityLabel("Response Body")
                .padding(AppConstants.postAndCommentSpacing)
                .focused($focusedField, equals: .editorBody)
                .onAppear {
                    focusedField = .editorBody
                }
                .onChange(of: editorBody) { newValue in
                    if editorModel.showSlurWarning {
                        do {
                            if let regex = siteInformation.slurFilterRegex {
                                if let output = try regex.firstMatch(in: newValue.lowercased()) {
                                    slurMatch = String(newValue[output.range])
                                } else {
                                    slurMatch = nil
                                }
                            }
                        } catch {
                            print("REGEX FAILED")
                        }
                    }
                }
                
                Divider()
                
                if let slurMatch {
                    VStack {
                        Text("\"\(slurMatch)\" is disallowed.")
                            .foregroundStyle(.white)
                        Text("You can still post this comment, but your instance will replace \"\(slurMatch)\" with \"*removed*\".")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius).fill(.red))
                    .padding(.horizontal, 10)
                } else {
                    editorModel.embeddedView()
                }
            }
            .animation(.default, value: slurMatch)
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
                    Image(systemName: Icons.send)
                }.disabled(isSubmitting || !isReadyToReply)
            }
        }
        .navigationBarColor()
        .navigationTitle(editorModel.modalName)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(isReadyToReply)
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

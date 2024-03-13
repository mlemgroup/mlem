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
    
    @StateObject var bodyEditorModel: BodyEditorModel = .init()
    @StateObject var attachmentModel: LinkAttachmentModel = .init(url: "")
    
    @FocusState private var focusedField: Field?

    private var isReadyToReply: Bool {
        editorBody.trimmed.isNotEmpty
    }
    
    var body: some View {
        NavigationStack(path: .constant(.init())) {
            ScrollView {
                VStack(spacing: AppConstants.standardSpacing) {
                    // Post Text
                    BodyEditorView(
                        text: $editorBody,
                        prompt: "What do you want to say?",
                        bodyEditorModel: bodyEditorModel,
                        attachmentModel: attachmentModel
                    )
                    .linkAttachmentModel(model: attachmentModel)
                    .lineLimit(AppConstants.textFieldVariableLineLimit)
                    .accessibilityLabel("Response Body")
                    .padding(AppConstants.standardSpacing)
                    .focused($focusedField, equals: .editorBody)
                    .onAppear {
                        focusedField = .editorBody
                    }
                    .onChange(of: editorBody) { newValue in
                        if editorModel.showSlurWarning {
                            slurMatch = siteInformation.instance?.firstSlurFilterMatch(newValue)
                        }
                    }
                    
                    Divider()
                    
                    infoView
                }
                .animation(.default, value: attachmentModel.imageModel?.state)
                .animation(.default, value: slurMatch)
                .padding(.bottom, AppConstants.editorOverscroll)
            }
            .scrollDismissesKeyboard(.automatic)
            .progressOverlay(isPresented: $isSubmitting)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .destructive) {
                        Task(priority: .background) {
                            await bodyEditorModel.deleteAllFiles()
                        }
                        dismiss()
                    }
                    .tint(.red)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    LinkUploadOptionsView(model: attachmentModel) {
                        Label("Attach Image or Link", systemImage: Icons.attachment)
                    }
                    // Submit Button
                    Button {
                        Task(priority: .userInitiated) {
                            await submit()
                        }
                        Task(priority: .background) {
                            await bodyEditorModel.deleteUnusedFiles(text: editorBody)
                        }
                    } label: {
                        Image(systemName: Icons.send)
                    }.disabled(isSubmitting || !isReadyToReply)
                }
            }
            .navigationBarColor()
            .navigationTitle(editorModel.modalName)
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(isReadyToReply)
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    var infoView: some View {
        switch attachmentModel.imageModel?.state {
        case .uploading(let progress):
            if progress == 1 {
                HStack(spacing: 20) {
                    Text("Processing...")
                    ProgressView()
                }
            } else {
                VStack {
                    Text("Uploading...")
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 80, height: 10)
                }
            }
        case .failed(let string):
            VStack {
                Text("Failed to upload")
                    .foregroundStyle(.red)
            }
        default:
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

//
//  CommunityDescriptionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-30.
//  

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct CommunityDescriptionEditorView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss

    let community: Community2

    @State var textView: UITextView = .init()
    @State var textHasChanged: Bool = false
    @State var sending: Bool = false
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var presentationSelection: PresentationDetent = .large

    init(community: Community2) {
        self.community = community
        textView.text = community.description ?? ""
    }

    var body: some View {

        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: !textHasChanged) {
            NavigationStack {
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButtonView(ios18Label: .cancel)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            if sending {
                                ProgressView()
                            } else {
                                sendButton
                            }
                        }
                    }
            }
        }
        .onChange(of: presentationSelection) {
            if presentationSelection == .large {
                textView.becomeFirstResponder()
            }
        }
        .onChange(of: navigation.isTopSheet) {
            if navigation.isTopSheet, navigation.model != nil {
                textView.becomeFirstResponder()
            }
        }
    }

    var content: some View {
        ScrollView {
            textEditorView
                .frame(
                    maxWidth: .infinity,
                    minHeight: minTextEditorHeight,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.vertical, Constants.main.standardSpacing)
                .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
                .paletteBorder(cornerRadius: Constants.main.standardSpacing)
                .padding(.horizontal, Constants.main.standardSpacing)
        }
        .background(.themedGroupedBackground)
        .presentationBackground(.themedGroupedBackground)
        .scrollBounceBehavior(.basedOnSize)
    }

    var textEditorView: some View {
        MarkdownTextEditor(
            onChange: { newValue in
                textHasChanged = newValue != (community.description ?? "") 
            },
            prompt: "Start writing...",
            textView: textView,
            content: {
                MarkdownEditorToolbarView(
                    textView: textView,
                    uploadHistory: uploadHistory,
                    model: markdownToolbarEditorModel
                )
            }
        )
    }

    @ViewBuilder
    var sendButton: some View {
        Button("Send", icon: community.description == nil ? .lemmy.send : .general.success) {
            sending = true
            Task(priority: .userInitiated) {
                await send()
            }
        }
        .disabled(!textHasChanged)
        .glassProminentButtonStyle()
    }

    func send() async {
        uploadHistory.deleteWhereNotPresent(in: textView.text)
        do {
            try await community.editDescription(textView.text)
            Task { @MainActor in
                textView.resignFirstResponder()
                textView.isEditable = false
                hapticManager.play(haptic: .success, tier: .low)
                dismiss()
            }
        } catch {
            sending = false
            handleError(error)
        }
    }

    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 15
    }
}

//
//  CommunityDescriptionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-30.
//  

import ComponentViews
import MlemMiddleware
import SwiftUI

struct CommunityDescriptionEditorView: View {
    @Environment(NavigationLayer.self) var navigation

    let community: Community2

    @State var textView: UITextView = .init()
    @State var textIsEmpty: Bool = true
    @State var markdownToolbarEditorModel: MarkdownEditorToolbarModel = .init()
    @State var uploadHistory: ImageUploadHistoryManager = .init()
    @State var presentationSelection: PresentationDetent = .large

    init(community: Community2) {
        self.community = community
        textView.text = community.description ?? ""
    }
    var body: some View {

        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: textIsEmpty) {
            NavigationStack {
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            CloseButtonView(ios18Label: .cancel)
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
            onChange: {
                if $0.isEmpty != textIsEmpty {
                    textIsEmpty = $0.isEmpty
                }
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

    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .body).lineHeight * 4 + 15
    }
}

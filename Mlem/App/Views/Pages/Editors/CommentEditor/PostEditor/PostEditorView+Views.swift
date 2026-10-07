//
//  PostEditorView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2024.
//

import SwiftUI

extension PostEditorView {
    @ViewBuilder
    var attachmentPickerView: some View {
        switch link {
        case let .value(link):
            PostEditorWebsitePreviewView(
                link: .init(
                    get: { link },
                    set: { self.link = .value($0) }
                ),
                imageManager: $thumbnailManager,
                primaryApi: primaryApi,
                removeCallback: {
                    self.link = .none
                },
                shouldBlur: false
            )
            .transition(.scale.combined(with: .opacity))
        default:
            HStack(spacing: 10) {
                if imageManager == nil, imageUrl == nil {
                    addLinkButton()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                if link == .none {
                    imageView
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    var targetSelectionView: some View {
        let showWarning = !targets.allSatisfy { $0.sendState != .failed }
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            if let postToEdit {
                ExpectedView(postToEdit.community) { community in
                    FullyQualifiedLinkView(community, labelStyle: .medium)
                        .padding(.horizontal, Constants.main.standardSpacing)
                } placeholder: {
                    Text(verbatim: .communityPlaceholder).redacted(reason: .placeholder)
                }
            } else {
                ForEach(Array(targets.enumerated()), id: \.element.id) { index, target in
                    HStack(spacing: Constants.main.standardSpacing) {
                        PostEditorTargetView(target: target, isMoreThanOneTarget: targets.count > 1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if targets.count > 1 {
                            Button("Remove", icon: .general.close) {
                                targets.remove(at: index)
                                checkSlurFilters()
                            }
                            .symbolVariant(.circle.fill)
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if showWarning {
                Text(targets.count == 1 ? "Post failed to send." : "One of more of your posts failed to send.")
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity)
                    .background(.opacity(0.2), in: .capsule)
                    .foregroundStyle(.themedNegative)
                    .padding(.horizontal)
            }
        }
        .animation(.easeOut(duration: 0.2), value: showWarning)
    }
 
    @ViewBuilder
    var nsfwTagView: some View {
        Button {
            hasNsfwTag = false
        } label: {
            HStack {
                Text("NSFW")
                    .font(.footnote)
                    .fontWeight(.black)
                    .foregroundStyle(.themedContrastingLabel)
                Image(icon: .general.close)
                    .foregroundStyle(.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(.themedWarning, in: .capsule)
        }
    }

    @ViewBuilder
    var titleTextView: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            MarkdownTextEditor(
                onChange: {
                    // Avoid unnecessary view update
                    if titleIsEmpty != $0.isEmpty {
                        titleIsEmpty = $0.isEmpty
                    }
                    checkSlurFilter(text: $0, slurMatches: $titleSlurMatches, pendingTask: $titleSlurTask)
                },
                prompt: "Title",
                textView: titleUiTextView,
                font: .preferredFont(forTextStyle: .title2),
                content: {
                    MarkdownEditorToolbarView(
                        showing: .inlineOnly,
                        textView: titleUiTextView,
                        model: .init()
                    )
                }
            )
            .frame(
                maxWidth: .infinity,
                minHeight: minTitleEditorHeight,
                maxHeight: .infinity,
                alignment: .topLeading
            )
  
            if !titleSlurMatches.isEmpty {
                FilterViolationWarning(failures: titleSlurMatches)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .padding(.bottom, Constants.main.standardSpacing)
            }
        }
        .padding(.top, Constants.main.halfSpacing)
        .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
    }

    @ViewBuilder
    var contentTextView: some View {
        VStack {
            MarkdownTextEditor(
                onChange: { newValue in
                    // Avoid unnecessary view update
                    if contentIsEmpty != newValue.isEmpty {
                        contentIsEmpty = newValue.isEmpty
                    }
                    checkSlurFilter(text: newValue, slurMatches: $bodySlurMatches, pendingTask: $bodySlurTask)
                },
                prompt: "Optional Description",
                textView: contentUiTextView,
                content: {
                    MarkdownEditorToolbarView(
                        textView: contentUiTextView,
                        uploadHistory: uploadHistory,
                        model: markdownToolbarEditorModel
                    )
                }
            )
            .onChange(of: primaryApi, initial: true) {
                markdownToolbarEditorModel.imageUploadApi = primaryApi
            }
            .frame(
                maxWidth: .infinity,
                minHeight: minTextEditorHeight,
                maxHeight: .infinity,
                alignment: .topLeading
            )

            if targets.count == 1,
                let first = targets.first,
                let ids = first.account.api.myPerson?.discussionLanguageIds.value,
                ids.count > 1 {
                LanguagePickerView(api: first.account.api, selected: $language)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, Constants.main.standardSpacing)
            }
  
            if !bodySlurMatches.isEmpty {
                FilterViolationWarning(failures: bodySlurMatches)
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .padding(.bottom, Constants.main.standardSpacing)
            }
        }
        .padding([.vertical, .bottom], Constants.main.standardSpacing)
        .background(
            .themedSecondaryGroupedBackground,
            in: UnevenRoundedRectangle(cornerRadii: .init(
                topLeading: Constants.main.standardSpacing,
                bottomLeading: Constants.main.standardSpacing,
                bottomTrailing: Constants.main.standardSpacing,
                topTrailing: Constants.main.standardSpacing
            ))
        )
    }
}

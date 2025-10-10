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
                FullyQualifiedLinkView(postToEdit.community, labelStyle: .medium)
                    .padding(.horizontal, Constants.main.standardSpacing)
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
}

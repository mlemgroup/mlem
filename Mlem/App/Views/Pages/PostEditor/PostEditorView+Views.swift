//
//  PostEditorView+Views.swift
//  Mlem
//
//  Created by Sjmarf on 30/09/2024.
//

import SwiftUI

extension PostEditorView {
    @ViewBuilder
    var targetSelectionView: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            if let postToEdit {
                FullyQualifiedLinkView(
                    entity: postToEdit.community,
                    labelStyle: .medium,
                    showAvatar: true
                )
                .padding(.horizontal)
                Divider()
            } else {
                ForEach(Array(targets.enumerated()), id: \.element.id) { index, target in
                    HStack(spacing: 0) {
                        PostEditorTargetView(target: target)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if targets.count > 1 {
                            Button("Remove", systemImage: Icons.closeCircleFill) {
                                targets.remove(at: index)
                            }
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.large)
                            .labelStyle(.iconOnly)
                            .padding(.trailing)
                        }
                    }
                    Divider()
                }
            }
            let showWarning = !targets.allSatisfy { $0.sendState != .failed }
            Group {
                if showWarning {
                    Text("One of more of your posts failed to send.")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                        .background(.opacity(0.2), in: .capsule)
                        .foregroundStyle(palette.negative)
                        .padding(.horizontal)
                }
            }.animation(.easeOut(duration: 0.2), value: showWarning)
        }
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
                    .foregroundStyle(palette.selectedInteractionBarItem)
                Image(systemName: Icons.close)
                    .foregroundStyle(.opacity(0.8))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(palette.warning, in: .capsule)
        }
    }
}

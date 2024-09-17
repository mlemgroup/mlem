//
//  PostEditorView+Toolbar.swift
//  Mlem
//
//  Created by Sjmarf on 02/09/2024.
//

import SwiftUI

extension PostEditorView {
    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Menu("Add", systemImage: "plus") {
                Toggle(
                    "Link",
                    systemImage: Icons.websiteAddress,
                    isOn: .init(get: { link != .none }, set: { link = $0 ? .waiting : .none })
                ).disabled(imageManager != nil)
                Toggle(
                    "Image",
                    systemImage: Icons.uploadImage,
                    isOn: .init(
                        get: { imageManager != nil },
                        set: { newValue in
                            if newValue {
                                imageManager = imageManager ?? .init()
                            } else {
                                Task {
                                    do {
                                        try await imageManager?.image?.delete()
                                    } catch {
                                        handleError(error)
                                    }
                                }
                                self.imageManager = nil
                            }
                        }
                    )
                )
                .disabled(link != .none)
                Toggle("NSFW Tag", systemImage: "tag", isOn: $hasNsfwTag)
                if postToEdit == nil {
                    Button("Crosspost", systemImage: "shuffle") {
                        if let account = targets.last?.account {
                            let newTarget: PostEditorTarget = .init(account: account)
                            targets.append(newTarget)
                            navigation.openSheet(.communityPicker(api: account.api, callback: { community in
                                newTarget.community = community
                            }))
                        }
                    }
                }
            }
            if self.sending {
                ProgressView()
            } else {
                Button("Send", systemImage: Icons.send) {
                    self.sending = true
                    Task { await submit() }
                }
                .disabled(!canSubmit)
            }
        }
    }
}

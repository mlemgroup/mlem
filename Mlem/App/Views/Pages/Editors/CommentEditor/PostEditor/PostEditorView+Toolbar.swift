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
            Menu("Add", icon: .general.add) {
                Toggle("NSFW Tag", icon: .lemmy.tag, isOn: $hasNsfwTag)
                if postToEdit == nil {
                    Button("Crosspost", systemImage: "shuffle") {
                        if let account = targets.last?.account {
                            let newTarget: PostEditorTarget = .init(account: account, onAccountChange: checkSlurFilters)
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
                Button("Send", icon: .lemmy.send) {
                    self.sending = true
                    Task { await submit() }
                }
                .disabled(!canSubmit)
            }
        }
    }
}

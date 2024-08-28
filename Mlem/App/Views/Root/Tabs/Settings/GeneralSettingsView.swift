//
//  GeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    
    @Setting(\.upvoteOnSave) var upvoteOnSave
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.markReadOnScroll) var markReadOnScroll
    
    var body: some View {
        Form {
            Section {
                Picker(selection: $blurNsfw) {
                    ForEach(NsfwBlurBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.label)
                    }
                } label: {
                    Text("Blur NSFW")
                }
                Toggle("Warn When Opening NSFW Community", isOn: $showNsfwCommunityWarning)
            } header: {
                Text("Safety")
            }
            
            Section {
                Toggle("Mark Read on Scroll", isOn: $markReadOnScroll)
                Toggle("Upvote on Save", isOn: $upvoteOnSave)
                Toggle("Swipe Actions", isOn: $swipeActionsEnabled)
                Picker("Jump Button", selection: $jumpButton) {
                    ForEach(CommentJumpButtonLocation.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
            }
        }
        .navigationTitle("General")
    }
}

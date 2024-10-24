//
//  GeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Dependencies
import SwiftUI

struct GeneralSettingsView: View {
    // safety
    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    
    // privacy
    @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    // behavior
    @Setting(\.upvoteOnSave) var upvoteOnSave
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.markReadOnScroll) var markReadOnScroll
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.defaultFeed) var defaultFeed
    @Setting(\.sidebarVisibleByDefault) var sidebarVisibleByDefault
    @Setting(\.confirmImageUploads) var confirmImageUploads
    @Setting(\.hapticLevel) var hapticLevel
    @Setting(\.wrapCodeBlockLines) var wrapCodeBlockLines
    
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
                Toggle("Auto-Bypass Image Proxy", isOn: $bypassImageProxy)
            } header: {
                Text("Privacy")
            }
            
            Section {
                Picker("Default Feed", selection: $defaultFeed) {
                    ForEach(FeedSelection.allCases, id: \.self) { item in
                        Text(item.rawValue.capitalized)
                    }
                }
                if UIDevice.isPad {
                    Toggle("Show Sidebar on App Launch", isOn: $sidebarVisibleByDefault)
                }
                if #available(iOS 18.0, *) {
                    Toggle("Autoplay Media", isOn: $autoplayMedia)
                }
                Toggle("Mark Read on Scroll", isOn: $markReadOnScroll)
                Toggle("Upvote on Save", isOn: $upvoteOnSave)
                Toggle("Swipe Actions", isOn: $swipeActionsEnabled)
                Picker("Jump Button", selection: $jumpButton) {
                    ForEach(CommentJumpButtonLocation.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
                Toggle("Confirm Image Uploads", isOn: $confirmImageUploads)
                Picker("Haptic Level", selection: $hapticLevel) {
                    ForEach(HapticPriority.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
                Toggle("Wrap Code Block Lines", isOn: $wrapCodeBlockLines)
            } header: {
                Text("Behavior")
            }
            
            NavigationLink("Import/Export Settings", destination: .settings(.importExportSettings))
        }
        .navigationTitle("General")
    }
}

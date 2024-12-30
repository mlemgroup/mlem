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
    @Setting(\.showModlogWarning) var showModlogWarning
    
    // privacy
    @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    // behavior
    @Setting(\.upvoteOnSave) var upvoteOnSave
    @Setting(\.jumpButton) var jumpButton
    @Setting(\.markReadOnScroll) var markReadOnScroll
    @Setting(\.infiniteScroll) var infiniteScroll
    @Setting(\.autoplayMedia) var autoplayMedia
    @Setting(\.muteVideos) var muteVideos
    @Setting(\.defaultFeed) var defaultFeed
    @Setting(\.sidebarVisibleByDefault) var sidebarVisibleByDefault
    @Setting(\.confirmImageUploads) var confirmImageUploads
    @Setting(\.hapticLevel) var hapticLevel
    @Setting(\.wrapCodeBlockLines) var wrapCodeBlockLines
    
    // Gestures
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    @Setting(\.swipeAnywhereToNavigate) var swipeAnywhereToNavigate
    
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
                Toggle("Warn When Opening Modlog", isOn: $showModlogWarning)
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
                Toggle("Mute Videos", isOn: $muteVideos)
                Toggle("Mark Read on Scroll", isOn: $markReadOnScroll)
                Toggle("Infinite Scroll", isOn: $infiniteScroll)
                Toggle("Upvote on Save", isOn: $upvoteOnSave)
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
            
            Section("Gestures") {
                Toggle(
                    "Swipe Actions",
                    isOn: .init(
                        get: { swipeActionsEnabled },
                        set: {
                            swipeActionsEnabled = $0
                            if $0 {
                                swipeAnywhereToNavigate = false
                            }
                        }
                    )
                )
                Toggle(
                    "Swipe Anywhere to Navigate",
                    isOn: .init(
                        get: { swipeAnywhereToNavigate },
                        set: {
                            swipeAnywhereToNavigate = $0
                            if $0 {
                                swipeActionsEnabled = false
                            }
                        }
                    )
                )
            }
            
            NavigationLink("Import/Export Settings", destination: .settings(.importExportSettings))
        }
        .navigationTitle("General")
    }
}

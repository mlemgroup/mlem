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
                Picker("Blur NSFW", systemImage: Icons.blurNsfw, selection: $blurNsfw) {
                    ForEach(NsfwBlurBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.label)
                    }
                }
                Toggle("Warn When Opening NSFW Community", systemImage: Icons.warning, isOn: $showNsfwCommunityWarning)
                Toggle("Warn When Opening Modlog", systemImage: Icons.warning, isOn: $showModlogWarning)
            } header: {
                Text("Safety")
            }
            
            Section {
                Toggle("Auto-Bypass Image Proxy", systemImage: Icons.proxy, isOn: $bypassImageProxy)
            } header: {
                Text("Privacy")
            }
            
            Section {
                Picker("Default Feed", systemImage: Icons.feeds, selection: $defaultFeed) {
                    ForEach(FeedSelection.allCases, id: \.self) { item in
                        Text(item.rawValue.capitalized)
                    }
                }
                if UIDevice.isPad {
                    Toggle("Show Sidebar on App Launch", systemImage: Icons.sidebar, isOn: $sidebarVisibleByDefault)
                }
                if #available(iOS 18.0, *) {
                    Toggle("Autoplay Media", systemImage: Icons.playCircle, isOn: $autoplayMedia)
                }
                Toggle("Mute Videos", systemImage: Icons.muted, isOn: $muteVideos)
                Toggle("Mark Read on Scroll", systemImage: Icons.read, isOn: $markReadOnScroll)
                Toggle("Infinite Scroll", systemImage: Icons.infiniteScroll, isOn: $infiniteScroll)
                Toggle("Upvote on Save", systemImage: Icons.upvoteOnSave, isOn: $upvoteOnSave)
                Toggle("Confirm Image Uploads", systemImage: Icons.confirmImageUploads, isOn: $confirmImageUploads)
                Picker("Haptic Level", systemImage: Icons.haptics, selection: $hapticLevel) {
                    ForEach(HapticPriority.allCases, id: \.self) { item in
                        Text(item.label)
                    }
                }
                Toggle("Wrap Code Block Lines", systemImage: Icons.inlineCode, isOn: $wrapCodeBlockLines)
            } header: {
                Text("Behavior")
            }
            
            Section("Gestures") {
                Toggle(
                    "Swipe Actions",
                    systemImage: Icons.swipeActions,
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
                    systemImage: Icons.swipeAnywhere,
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
            
            NavigationLink("Import/Export Settings", systemImage: Icons.importSettings, destination: .settings(.importExportSettings))
        }
        .labelStyle(.conditional)
        .navigationTitle("General")
    }
}

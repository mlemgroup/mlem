//
//  SettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import Nuke
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.blurNsfw) var blurNsfw
    @Setting(\.showNsfwCommunityWarning) var showNsfwCommunityWarning
    
    @Setting(\.upvoteOnSave) var upvoteOnSave
    @Setting(\.quickSwipesEnabled) var swipeActionsEnabled
    
    var accounts: [UserAccount] { AccountsTracker.main.userAccounts }
    
    var body: some View {
        Form {
            Section {
                accountSettingsLink
                accountListLink
            }
            Section {
                NavigationLink("Links", destination: .settings(.links))
                NavigationLink("Sorting", destination: .settings(.sorting))
            }
            
            Section {
                NavigationLink("Post", destination: .settings(.postInteractionBar))
                NavigationLink("Comment", destination: .settings(.commentInteractionBar))
                NavigationLink("Reply", destination: .settings(.replyInteractionBar))
            }
            
            Section {
                NavigationLink("Theme", destination: .settings(.theme))
                NavigationLink("App Icon", destination: .settings(.icon))
                NavigationLink("Subscription List", destination: .settings(.subscriptionList))
                NavigationLink("Posts", destination: .settings(.post))
            }
            
            Section {
                Picker(selection: $blurNsfw) {
                    ForEach(NsfwBlurBehavior.allCases, id: \.self) { behavior in
                        Text(behavior.label)
                    }
                } label: {
                    Text("Blur NSFW")
                }
                Toggle("Warn when opening NSFW community", isOn: $showNsfwCommunityWarning)
            } header: {
                Text("Safety")
            }
            
            Section {
                Toggle("Upvote On Save", isOn: $upvoteOnSave)
                Toggle("Swipe Actions", isOn: $swipeActionsEnabled)
            }
            Section {
                Button("Clear Cache") {
                    URLCache.shared.removeAllCachedResponses()
                    ImagePipeline.shared.cache.removeAll()
                }
            }
            
            Section {
                Button("Search Communities") {
                    navigation.openSheet(.communityPicker(callback: { print($0.name) }))
                }
                
                Button("Search People") {
                    navigation.openSheet(.personPicker(callback: { print($0.name) }))
                }
                
                Button("Search Instances") {
                    navigation.openSheet(.instancePicker(callback: { print($0.name) }))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var accountSettingsLink: some View {
        NavigationLink(.settings(.account)) {
            let account = appState.firstSession
            HStack(spacing: 23) {
                CircleCroppedImageView(account.account)
                    .frame(width: 54, height: 54)
                    .padding(.vertical, -6)
                    .padding(.leading, 3)
                VStack(alignment: .leading, spacing: 3) {
                    Text(account is UserSession ? account.account.nickname : "Guest")
                        .font(.title2)
                    Text(accountSettingsLinkSubtitle)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Spacer()
            }
        }
    }
    
    var accountSettingsLinkSubtitle: String {
        if let host = appState.firstSession.account.host {
            return "@\(host)"
        }
        return ""
    }
    
    var accountListLink: some View {
        NavigationLink(.settings(.accounts)) {
            HStack(spacing: 10) {
                AvatarStackView(
                    urls: accounts.prefix(4).map(\.avatar),
                    fallback: .person,
                    spacing: accounts.count <= 3 ? 18 : 14,
                    outlineWidth: 0.7,
                    showPlusIcon: accounts.count == 1
                )
                .frame(height: 28)
                .frame(minWidth: 80)
                .padding(.leading, -10)
                Text("Accounts")
                Spacer()
                Text(String(accounts.count))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

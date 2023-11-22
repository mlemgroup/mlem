//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import Dependencies

struct SettingsView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @StateObject private var settingsTabNavigation: AnyNavigationPath<AppRoute> = .init()

    @Environment(\.openURL) private var openURL

    @Namespace var scrollToTop
    
    var body: some View {
        NavigationStack(path: $settingsTabNavigation.path) {
            ScrollViewReader { _ in
                List {
                    Section {
                        NavigationLink { EmptyView() } label: {
                            HStack(spacing: 20) {
                                AvatarView(url: appState.profileTabRemoteSymbolUrl, type: .user, avatarSize: 60, iconResolution: 512)
                                    .padding(.vertical, -8)
                                if let account = appState.currentActiveAccount {

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(account.nickname)
                                            .font(.title2)
                                        if let hostName = account.hostName {
                                            Text("@\(hostName)")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        NavigationLink(.settings(.accounts)) {
                            HStack(spacing: 10) {
                                HStack {
                                    HStack {
                                        ForEach(accountsTracker.savedAccounts.prefix(4), id: \.id) { account in
                                            AvatarView(
                                                url: account.avatarUrl,
                                                type: .user,
                                                avatarSize: 28,
                                                lineWidth: 0
                                            )
                                            .padding(1.8)
                                            .background {
                                                Circle()
                                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                            }
                                            .frame(maxWidth: 8)
                                        }
                                    }
                                }
                                .frame(minWidth: 80)
                                .padding(.leading, -10)
                                Text("Accounts")
                                Spacer()
                                Text("\(accountsTracker.savedAccounts.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .id(scrollToTop)
                    }
                    Section {
                        NavigationLink(.settings(.general)) {
                            Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                        
                        NavigationLink(.settings(.sorting)) {
                            Label("Sorting", systemImage: "arrow.up.and.down.text.horizontal")
                                .labelStyle(SquircleLabelStyle(color: .indigo))
                        }
                        
                        NavigationLink(.settings(.contentFilters)) {
                            Label("Content Filters", systemImage: "line.3.horizontal.decrease")
                                .labelStyle(SquircleLabelStyle(color: .orange))
                        }
                        
                        NavigationLink(.settings(.accessibility)) {
                            // apparently the Apple a11y symbol isn't an SFSymbol
                            Label("Accessibility", systemImage: "hand.point.up.braille.fill").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                        
                        NavigationLink(.settings(.appearance)) {
                            Label("Appearance", systemImage: "paintbrush.fill").labelStyle(SquircleLabelStyle(color: .pink))
                        }
                    }
                    
                    Section {
                        NavigationLink(.settings(.about)) {
                            Label("About Mlem", systemImage: "info").labelStyle(SquircleLabelStyle(color: .blue))
                        }
                    }
                    
                    Section {
                        NavigationLink(.settings(.advanced)) {
                            Label("Advanced", systemImage: "gearshape.2.fill").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                    }
                }
                .reselectAction(tab: TabSelection.settings) {
                    print("re-selected settings")
                }
            }
            .environmentObject(settingsTabNavigation)
            .fancyTabScrollCompatible()
            .handleLemmyViews()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor()
        }
        .handleLemmyLinkResolution(navigationPath: .constant(settingsTabNavigation))
    }
}

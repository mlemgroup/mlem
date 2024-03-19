//
//  Settings View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

struct SettingsView: View {
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @StateObject private var settingsTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    @State private var isShowingInstanceAdditionSheet: Bool = false
    
    @Environment(\.openURL) private var openURL
    
    @Namespace var scrollToTop
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $settingsTabNavigation.path) {
                List {
                    Section {
                        NavigationLink(.settings(.currentAccount)) {
                            HStack(spacing: 23) {
                                AvatarView(
                                    url: appState.profileTabRemoteSymbolUrl,
                                    type: .user,
                                    avatarSize: 54,
                                    iconResolution: .unrestricted
                                )
                                .padding(.vertical, -6)
                                .padding(.leading, 3)
                                if let person = siteInformation.myUserInfo?.localUserView.person {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(appState.currentActiveAccount?.nickname ?? person.name)
                                            .font(.title2)
                                        if let hostName = person.actorId.host() {
                                            Text("@\(hostName)")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .id(scrollToTop)
                        }
                        if accountsTracker.savedAccounts.count > 1 {
                            NavigationLink(.settings(.accounts)) {
                                HStack(spacing: 10) {
                                    AccountIconStack(
                                        accounts: Array(accountsTracker.savedAccounts.prefix(4)),
                                        avatarSize: 28,
                                        spacing: 8,
                                        outlineWidth: 1.8,
                                        backgroundColor: Color(UIColor.secondarySystemGroupedBackground)
                                    )
                                    .frame(minWidth: 80)
                                    .padding(.leading, -10)
                                    Text("Accounts")
                                    Spacer()
                                    Text("\(accountsTracker.savedAccounts.count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            Button {
                                isShowingInstanceAdditionSheet = true
                            } label: {
                                Label("Add Another Account", systemImage: Icons.add)
                            }
                            .sheet(isPresented: $isShowingInstanceAdditionSheet) {
                                AddSavedInstanceView(onboarding: false)
                            }
                        }
                    }
                    Section {
                        NavigationLink(.settings(.general)) {
                            Label("General", systemImage: "gear").labelStyle(SquircleLabelStyle(color: .gray))
                        }
                        NavigationLink(.settings(.links)) {
                            Label("Links", systemImage: "link").labelStyle(SquircleLabelStyle(color: .teal))
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
                .environmentObject(settingsTabNavigation)
                .fancyTabScrollCompatible()
                .handleLemmyViews()
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor()
                .tabBarNavigationEnabled(.settings, navigation)
                .hoistNavigation {
                    withAnimation {
                        proxy.scrollTo(scrollToTop, anchor: .bottom)
                    }
                    return true
                }
            }
            .handleLemmyLinkResolution(navigationPath: .constant(settingsTabNavigation))
            .environment(\.navigationPathWithRoutes, $settingsTabNavigation.path)
            .environment(\.navigation, navigation)
        }
    }
}

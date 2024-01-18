//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import SwiftUI
import Dependencies

struct ProfileView: View {
    // appstorage
    @Dependency(\.siteInformation) var siteInformation
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true

    @StateObject private var profileTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    @State var isPresentingAccountSwitcher: Bool = false
    @State var isPresentingProfileEditor: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $profileTabNavigation.path) {
                if let person = siteInformation.myUserInfo?.localUserView.person {
                    UserView(user: UserModel(from: person))
                        .handleLemmyViews()
                        .environmentObject(profileTabNavigation)
                        .tabBarNavigationEnabled(.profile, navigation)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Switch Account", systemImage: Icons.switchUser) {
                                    isPresentingAccountSwitcher = true
                                }
                            }
                            // TODO: 0.17 deprecation
                            if (siteInformation.version ?? .infinity) >= .init("0.18.0") {
                                ToolbarItem(placement: .secondaryAction) {
                                    Button("Edit", systemImage: Icons.edit) {
                                        isPresentingProfileEditor = true
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $isPresentingAccountSwitcher) {
                            Form {
                                AccountListView()
                            }
                        }
                        .sheet(isPresented: $isPresentingProfileEditor) {
                            NavigationStack {
                                ProfileSettingsView(showCloseButton: true)
                            }
                        }
                } else {
                    LoadingView(whatIsLoading: .profile)
                        .fancyTabScrollCompatible()
                }
            }
            .handleLemmyLinkResolution(navigationPath: .constant(profileTabNavigation))
            .environment(\.navigationPathWithRoutes, $profileTabNavigation.path)
            .environment(\.scrollViewProxy, proxy)
            .environment(\.navigation, navigation)
        }
    }
}

//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Dependencies
import SwiftUI

struct ProfileView: View {
    // appstorage
    @Dependency(\.siteInformation) var siteInformation
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    @StateObject private var profileTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var editorSheetNavigation: AnyNavigationPath<AppRoute> = .init()
    
    @StateObject private var navigation: Navigation = .init()
    @StateObject private var sheetNavigation: Navigation = .init()
    
    @State var isPresentingAccountSwitcher: Bool = false
    @State var isPresentingProfileEditor: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $profileTabNavigation.path) {
                if let person = siteInformation.myUserInfo?.localUserView.person {
                    UserView(user: UserModel(from: person), isPresentingProfileEditor: $isPresentingProfileEditor)
                        .handleLemmyViews()
                        .environmentObject(profileTabNavigation)
                        .tabBarNavigationEnabled(.profile, navigation)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Switch Account", systemImage: Icons.switchUser) {
                                    isPresentingAccountSwitcher = true
                                }
                            }
                            
                        }
                        .sheet(isPresented: $isPresentingAccountSwitcher) {
                            Form {
                                AccountListView()
                            }
                        }
                        .sheet(isPresented: $isPresentingProfileEditor) {
                            NavigationStack(path: $editorSheetNavigation.path) {
                                ProfileSettingsView(showCloseButton: true)
                                    .handleLemmyViews()
                                    .environmentObject(editorSheetNavigation)
                            }
                            .handleLemmyLinkResolution(navigationPath: .constant(editorSheetNavigation))
                            .environment(\.navigationPathWithRoutes, $editorSheetNavigation.path)
                            .environment(\.navigation, sheetNavigation)
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

//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import SwiftUI

struct ProfileView: View {
    
    let user: UserModel?

    @StateObject private var profileTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationStack(path: $profileTabNavigation.path) {
                if let user {
                    UserView(user: user)
                        .handleLemmyViews()
                        .environmentObject(profileTabNavigation)
                        .tabBarNavigationEnabled(.profile, navigation)
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

//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import SwiftUI

// Profile tab view
struct ProfileView: View {
    // appstorage
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    let userID: Int

    @StateObject private var profileTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        NavigationStack(path: $profileTabNavigation.path) {
            UserView(userID: userID)
                .handleLemmyViews()
                .environmentObject(profileTabNavigation)
                .tabBarNavigationEnabled(.profile, navigation)
        }
        .handleLemmyLinkResolution(navigationPath: .constant(profileTabNavigation))
        .environment(\.navigationPathWithRoutes, $profileTabNavigation.path)
        .environmentObject(navigation)
    }
}

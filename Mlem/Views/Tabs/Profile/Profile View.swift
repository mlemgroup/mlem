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
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue

    @StateObject private var profileTabNavigation: AnyNavigationPath<AppRoute> = .init()
    
    var body: some View {
        NavigationStack(path: $profileTabNavigation.path) {
            UserView(userID: userID)
                .handleLemmyViews()
        }
        .handleLemmyLinkResolution(navigationPath: .constant(profileTabNavigation))
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.profile.hashValue {
                print("switched to Profile tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.profile.hashValue {
                print("re-selected \(TabSelection.profile) tab")
            }
        }
    }
}

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
    
    // environment
    @EnvironmentObject var appState: AppState
    
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue

    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            UserView(userID: userID)
                .handleLemmyViews()
        }
        .handleLemmyLinkResolution(navigationPath: $navigationPath)
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.profile.hashValue {
                print("switched to Profile tab")
            }
        }
    }
}

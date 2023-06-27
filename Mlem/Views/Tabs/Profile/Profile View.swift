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
    
    // environment
    @EnvironmentObject var appState: AppState
    
    // parameters
    @State var account: SavedAccount

    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            UserView(userID: account.id, account: account)
                .handleLemmyViews(navigationPath: $navigationPath)
        }
    }
}

//
//  Profile Tab View.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Dependencies
import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) var appState
    @AppStorage("upvoteOnSave") var upvoteOnSave = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
        }
    }
    
    var content: some View {
        VStack {
            Text("\(appState.firstAccount.myUser?.name ?? "No User")")
            Text("\(appState.firstApi.baseUrl)")
            Text((appState.firstAccount.myUser as? User)?.displayName ?? "...")
            Divider()
            Toggle("Upvote On Save", isOn: $upvoteOnSave)
                .padding(.horizontal, 50)
        }
    }
}

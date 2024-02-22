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
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
        }
    }
    
    var content: some View {
        Text(appState.myUser?.name ?? "No User!")
    }
}

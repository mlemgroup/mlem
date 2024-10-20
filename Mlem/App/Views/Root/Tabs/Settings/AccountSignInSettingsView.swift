//
//  AccountSignInSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountSignInSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    var body: some View {
        Form {
            Section {
                NavigationLink(.settings(.accountChangeEmail)) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(appState.firstPerson?.email ?? "")
                            .foregroundStyle(palette.secondary)
                    }
                }
            }
        }
        .navigationTitle("Sign-In & Security")
    }
}

//
//  AccountSignInSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountSignInSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        Form {
            Section {
                NavigationLink(.settings(.accountChangeEmail)) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(appState.firstPerson?.email.value as? String ?? "")
                            .foregroundStyle(.themedSecondary)
                    }
                }
            }
            Section {
                Button("Change Password", icon: .general.security) {
                    navigation.openSheet(.settings(.accountChangePassword))
                }
            }
        }
        .withConditionalLabelStyle()
        .navigationTitle("Sign-In & Security")
    }
}

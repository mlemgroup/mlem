//
//  AccountSignInSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountSignInSettingsView: View {
    @Environment(Palette.self) var palette
    
    var body: some View {
        Form {
            Section {
                NavigationLink(.settings(.accountChangeEmail)) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text((AppState.main.firstSession as? UserSession)?.person?.email ?? "")
                            .foregroundStyle(palette.secondary)
                    }
                }
            }
            Section {
                Button("Change Password") {}
            }
        }
        .navigationTitle("Sign-In & Security")
    }
}

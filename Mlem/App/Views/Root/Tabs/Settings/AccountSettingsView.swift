//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: AppConstants.standardSpacing) {
                    AvatarBannerView(appState.firstAccount.person)
                    VStack(spacing: 5) {
                        Text(appState.firstAccount.person?.displayName ?? "Guest")
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        if let person = appState.firstAccount.person, let hostName = person.host {
                            Text("@\(person.name)@\(hostName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(.systemGroupedBackground))
                .padding(.vertical, -12)
                .padding(.horizontal, -16)
            }
        }
        .navigationTitle("Account")
    }
}

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
                    if let userAccount = appState.firstAccount as? ActiveUserAccount {
                        AvatarBannerView(userAccount.person)
                    } else {
                        AvatarBannerView(appState.firstAccount.instance)
                    }
                    VStack(spacing: 5) {
                        Text(title)
                            .font(.title)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
    
    var title: String {
        if let userAccount = appState.firstAccount as? ActiveUserAccount {
            return userAccount.person?.displayName ?? "Account"
        } else {
            return appState.firstAccount.instance?.displayName ?? "User"
        }
    }
    
    var subtitle: String {
        if let userAccount = appState.firstAccount as? ActiveUserAccount {
            return userAccount.person?.fullNameWithPrefix ?? "Loading..."
        }
        return appState.firstAccount.instance?.name ?? "Loading..."
    }
}

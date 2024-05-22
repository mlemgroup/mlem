//
//  AccountListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 08/05/2024.
//

import MlemMiddleware
import SwiftUI

struct AccountListSettingsView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(AppState.self) var appState
    
    var accounts: [Account] { AccountsTracker.main.savedAccounts }
    
    var body: some View {
        Form {
            headerView
            AccountListView()
            Button("Re-authenticate", systemImage: "arrow.2.circlepath") {
                if let account = appState.firstAccount.account {
                    navigation.openSheet(.login(.reauth(account)))
                }
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        Section {
            VStack(alignment: .center) {
                Group {
                    if accounts.count >= 2 {
                        AvatarStackView(
                            urls: accounts.map(\.avatar),
                            type: .person,
                            spacing: 42,
                            outlineWidth: 1
                        )
                    } else {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                }
                .frame(height: 64)
                .padding(.top, -12)
                
                Text("Accounts")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(.systemGroupedBackground))
        }
    }
}

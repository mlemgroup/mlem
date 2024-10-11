//
//  AccountListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 08/05/2024.
//

import MlemMiddleware
import SwiftUI

struct AccountListSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Setting(\.keepPlaceOnAccountSwitch) var keepPlace

    var accounts: [UserAccount] { AccountsTracker.main.userAccounts }
    
    var body: some View {
        Form {
            headerView
            AccountListView()
            Section {
                Toggle("Reload on Switch", isOn: $keepPlace.invert())
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        // empty section disables background
        Section {} header: {
            VStack(alignment: .center) {
                Group {
                    if accounts.count >= 2 {
                        AvatarStackView(
                            urls: accounts.map(\.avatar),
                            fallback: .person,
                            height: 64,
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
                
                Text("Accounts")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(palette.primary) // override default .secondary style
        }
        .textCase(nil) // override default all-caps
    }
}

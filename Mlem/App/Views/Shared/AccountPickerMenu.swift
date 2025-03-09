//
//  AccountPickerMenu.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import SwiftUI

struct AccountPickerMenu<Content: View>: View {
    var accountsTracker: AccountsTracker { .main }
    
    @Binding var account: UserAccount
    let content: Content
    
    init(account: Binding<UserAccount>, @ViewBuilder content: () -> Content) {
        self._account = account
        self.content = content()
    }
    
    var body: some View {
        Menu {
            Picker("Switch Account", selection: $account) {
                ForEach(accountsTracker.userAccounts, id: \.actorId) { account in
                    Button {} label: {
                        Label(account)
                        Text(verbatim: "@\(account.host)")
                    }
                    .tag(account)
                }
            }
            .pickerStyle(.inline)
        } label: {
            // This `Button` wrapper is necessary, otherwise the `Picker` won't work.
            Button(action: {}, label: {
                content
            })
        }
        .buttonStyle(.plain)
    }
}

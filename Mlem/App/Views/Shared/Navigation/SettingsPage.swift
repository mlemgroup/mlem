//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

enum SettingsPage: Hashable {
    case root, accounts
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .root:
            SettingsView()
        case .accounts:
            Text("Accounts")
        }
    }
}

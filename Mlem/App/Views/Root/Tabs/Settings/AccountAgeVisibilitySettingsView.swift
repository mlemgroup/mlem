//
//  AccountAgeVisibilitySettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-04-23.
//

import SwiftUI

struct AccountAgeVisibilitySettingsView: View {
    @Setting(\.person_ageVisibility) var accountAgeVisibility
    
    var body: some View {
        Form {
            Picker("Account Age Visibility", selection: $accountAgeVisibility) {
                ForEach(AccountAgeFlairVisibility.allCases, id: \.self) { visibility in
                    Text(visibility.rawValue)
                        .tag(visibility)
                }
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
    }
}

enum AccountAgeFlairVisibility: String, Codable, CaseIterable {
    case always, newAccountsOnly, never
    
    var label: LocalizedStringResource {
        switch self {
        case .always:
            "Always"
        case .newAccountsOnly:
            "For New Accounts Only"
        case .never:
            "Never"
        }
    }
}

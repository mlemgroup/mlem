//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 09/09/2023.
//

import SwiftUI

struct AccountSettingsView: View {
    @Binding var displayName: String
    
    var body: some View {
        Form {
            Section {
                TextField("Display Name", text: $displayName)
            }
        }
        .navigationTitle("Account Settings")
    }
}

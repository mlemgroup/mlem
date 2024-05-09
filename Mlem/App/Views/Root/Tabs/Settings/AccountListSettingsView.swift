//
//  AccountListSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 08/05/2024.
//

import SwiftUI

struct AccountListSettingsView: View {
    var body: some View {
        Form {
            headerView()
            AccountListView()
        }
    }
    
    @ViewBuilder
    func headerView() -> some View {
        Section {
            VStack(alignment: .center) {
                AvatarStackView(
                    urls: [nil, nil, nil],
                    type: .person,
                    spacing: 48,
                    outlineWidth: 2.6
                )
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

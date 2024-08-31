//
//  InboxSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct InboxSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(
                    "Customize Interaction Bar",
                    systemImage: "square.and.line.vertical.and.square.fill",
                    destination: .settings(.replyInteractionBar)
                )
            }
        }
        .navigationTitle("Inbox")
    }
}

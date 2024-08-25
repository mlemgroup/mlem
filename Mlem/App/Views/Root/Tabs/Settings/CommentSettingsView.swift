//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct CommentSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(
                    "Customize Interaction Bar",
                    systemImage: "square.and.line.vertical.and.square.fill",
                    destination: .settings(.commentInteractionBar)
                )
            }
        }
        .navigationTitle("Comments")
    }
}

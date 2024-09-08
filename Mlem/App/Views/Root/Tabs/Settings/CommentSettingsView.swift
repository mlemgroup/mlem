//
//  CommentSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import SwiftUI

struct CommentSettingsView: View {
    @Setting(\.compactComments) var compactComments
    
    var body: some View {
        Form {
            Section {
                Toggle("Compact Comments", isOn: $compactComments)
            }
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

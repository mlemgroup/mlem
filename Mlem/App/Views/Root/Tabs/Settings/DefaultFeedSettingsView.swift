//
//  DefaultFeedSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-31.
//

import SwiftUI

struct DefaultFeedSettingsView: View {
    @Setting(\.defaultFeed) var defaultFeed
    
    var body: some View {
        Form {
            SettingsHeaderView(
                title: "Default Feed",
                description: "Choose which feed is shown when the app opens."
            ) {}
            Picker("Default Feed", selection: $defaultFeed) {
                ForEach(FeedSelection.allCases, id: \.self) { item in
                    Label {
                        Text(item.description.label)
                    } icon: {
                        FeedIconView(feedDescription: item.description, size: 30)
                    }
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .contentMargins(.top, 16)
        .hiddenNavigationTitle("Default Feed")
    }
}

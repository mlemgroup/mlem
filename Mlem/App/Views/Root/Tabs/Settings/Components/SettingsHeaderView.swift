//
//  SettingsHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import SwiftUI

struct SettingsHeaderView<Icon: View>: View {
    @Environment(Palette.self) var palette
    
    let title: String
    let description: String?
    let icon: Icon
        
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource?,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.title = .init(localized: title)
        if let description {
            self.description = .init(localized: description)
        } else {
            self.description = nil
        }
        self.icon = icon()
    }
    
    var body: some View {
        Section {
            VStack(spacing: 15) {
                icon
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                if let description {
                    Text(description)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, Constants.main.standardSpacing)
        }
    }
}

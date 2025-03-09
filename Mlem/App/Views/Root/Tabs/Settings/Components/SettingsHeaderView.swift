//
//  SettingsHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import SwiftUI

struct SettingsHeaderView<Icon: View>: View {
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
            VStack(spacing: 12) {
                icon
                    .padding(.bottom, 5)
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.main.standardSpacing)
        }
    }
}

struct SettingsHeaderIconView: View {
    let systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.title)
            .imageScale(.large)
            .foregroundStyle(.themedContrastingLabel)
            .frame(width: 60, height: 60)
            .background(.tint, in: .rect(cornerRadius: 15))
    }
}

extension SettingsHeaderView {
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource?,
        systemImage: String
    ) where Icon == SettingsHeaderIconView {
        self.init(title: title, description: description) {
            SettingsHeaderIconView(systemName: systemImage)
        }
    }
}

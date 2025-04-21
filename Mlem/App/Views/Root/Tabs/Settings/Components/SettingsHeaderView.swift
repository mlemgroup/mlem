//
//  SettingsHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-17.
//

import Icons
import SwiftUI

struct SettingsHeaderView<IconView: View>: View {
    let title: String
    let description: String?
    let icon: IconView
        
    init(
        title: LocalizedStringResource,
        description: LocalizedStringResource?,
        @ViewBuilder icon: @escaping () -> IconView
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
                    .symbolVariant(.fill)
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
    let icon: Icon
    
    var body: some View {
        Image(icon: icon)
            .font(.title)
            .symbolVariant(.fill)
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
        icon: Icon
    ) where IconView == SettingsHeaderIconView {
        self.init(title: title, description: description) {
            SettingsHeaderIconView(icon: icon)
        }
    }
}

//
//  NavigationLink+NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

extension NavigationLink where Destination == Never {
    init(_ value: NavigationPage, @ViewBuilder label: () -> Label) {
        self.init(value: value, label: label)
    }
    
    init(_ titleKey: LocalizedStringResource, destination: NavigationPage) where Label == Text {
        self.init(value: destination) { Text(titleKey) }
    }
    
    init(
        _ titleKey: LocalizedStringResource,
        value: String,
        fallbackValue: String,
        systemImage: String? = nil,
        destination: NavigationPage
    ) where Label == NavigationLinkPickerLabelView {
        self.init(destination) {
            NavigationLinkPickerLabelView(
                title: .init(localized: titleKey),
                value: value,
                fallbackValue: fallbackValue,
                systemImage: systemImage
            )
        }
    }
    
    @_disfavoredOverload
    init(_ title: String, destination: NavigationPage) where Label == Text {
        self.init(value: destination) { Text(title) }
    }
    
    init(
        _ titleKey: LocalizedStringResource,
        systemImage: String,
        destination: NavigationPage
    ) where Label == SwiftUI.Label<Text, Image> {
        self.init(value: destination) { Label(String(localized: titleKey), systemImage: systemImage) }
    }
}

struct NavigationLinkPickerLabelView: View {
    let title: String
    let value: String
    let fallbackValue: String
    let systemImage: String?
    
    var body: some View {
        HStack(spacing: 10) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ViewThatFits {
                Text(value)
                Text(fallbackValue)
            }
            .foregroundStyle(.themedSecondary)
            .lineLimit(1)
        }
    }
}

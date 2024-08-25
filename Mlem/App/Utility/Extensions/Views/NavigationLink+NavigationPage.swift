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
    
    @_disfavoredOverload
    init(_ title: String, destination: NavigationPage) where Label == Text {
        self.init(value: destination) { Text(title) }
    }
    
    init(_ titleKey: LocalizedStringResource, systemImage: String, destination: NavigationPage) where Label == SwiftUI.Label<Text, Image> {
        self.init(value: destination) { Label(String(localized: titleKey), systemImage: systemImage) }
    }
}

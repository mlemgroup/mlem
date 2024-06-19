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
    
    init(_ titleKey: LocalizedStringKey, destination: NavigationPage) where Label == Text {
        self.init(value: destination) { Text(titleKey) }
    }
    
    init(_ titleKey: LocalizedStringKey, systemImage: String, destination: NavigationPage) where Label == SwiftUI.Label<Text, Image> {
        self.init(value: destination) { Label(titleKey, systemImage: systemImage) }
    }
}

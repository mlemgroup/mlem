//
//  TabBarElement.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import SwiftUI

struct CustomTabItem: View {
    var content: AnyView
    
    var title: String
    var image: String
    var selectedImage: String
    var badge: BadgeUpdater?
    
    var onLongPress: (() -> Void)?
    
    init(
        title: LocalizedStringResource,
        image: String,
        selectedImage: String? = nil,
        badge: BadgeUpdater? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = String(localized: title)
        self.image = image
        self.selectedImage = selectedImage ?? image
        self.onLongPress = onLongPress
        self.badge = badge
        self.content = AnyView(content())
    }
    
    var body: some View { content }
}

// This is a janky workaround - if `badge` is simply included as a property in
// `CustomTabItem`, the entire `ContentView` is reset when the badge changes.

@Observable
class BadgeUpdater {
    var wrappedValue: String?
}

//
//  TabBarElement.swift
//  Mlem
//
//  Created by Sjmarf on 11/04/2024.
//

import SwiftUI

struct CustomTabItem {
    var content: AnyView
    
    var title: String
    var image: UIImage?
    var selectedImage: UIImage?
    var badge: String?
    
    var onLongPress: (() -> Void)?
    
    @_disfavoredOverload // This ensures that the other initialiser takes priority
    init(
        title: String,
        image: UIImage?,
        selectedImage: UIImage? = nil,
        badge: String? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage ?? image
        self.onLongPress = onLongPress
        self.badge = badge
        self.content = AnyView(content())
    }
    
    init(
        title: LocalizedStringResource,
        image: UIImage?,
        selectedImage: UIImage? = nil,
        badge: String? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.init(
            title: String(localized: title),
            image: image,
            selectedImage: selectedImage,
            badge: badge,
            onLongPress: onLongPress,
            content: content
        )
    }
}

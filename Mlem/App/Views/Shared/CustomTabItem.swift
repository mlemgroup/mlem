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
    
    var onLongPress: (() -> Void)?
    
    init(
        title: String,
        image: String,
        selectedImage: String? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage ?? image
        self.onLongPress = onLongPress
        self.content = AnyView(content())
    }
    
    var body: some View { content }
}

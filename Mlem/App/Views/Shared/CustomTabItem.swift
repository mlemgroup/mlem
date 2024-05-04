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
    var systemImage: String
    
    var onLongPress: (() -> Void)?
    
    init(
        title: String,
        systemImage: String,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: () -> some View
    ) {
        self.title = title
        self.systemImage = systemImage
        self.onLongPress = onLongPress
        self.content = AnyView(content())
    }
    
    var body: some View { content }
}

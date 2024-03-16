//
//  ToolbarEllipsisMenu.swift
//  Mlem
//
//  Created by Sjmarf on 16/03/2024.
//

import SwiftUI

struct ToolbarEllipsisMenu<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Menu {
            content
        } label: {
            Label("More", systemImage: Icons.menuCircle)
                .frame(height: AppConstants.barIconHitbox)
                .contentShape(Rectangle())
        }
    }
}

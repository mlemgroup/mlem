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
    
    init(_ actions: [any Action]) where Content == ForEach<[any Action], String, MenuButton> {
        self.init(content: {
            ForEach(actions, id: \.id) { action in
                MenuButton(action: action)
            }
        })
    }
    
    var body: some View {
        Menu {
            content
        } label: {
            Label("More", systemImage: Icons.menuCircle)
                .frame(height: Constants.main.barIconHitbox)
                .contentShape(Rectangle())
        }
        .popupAnchor()
    }
}

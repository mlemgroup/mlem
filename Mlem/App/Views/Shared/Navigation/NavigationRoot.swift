//
//  NavigationRoot.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

struct NavigationRoot<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            content()
        }
    }
}

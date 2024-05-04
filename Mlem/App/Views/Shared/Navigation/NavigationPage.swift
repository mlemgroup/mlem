//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

enum NavigationPage: Hashable {
    case dummy
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        EmptyView()
    }
    
    var hasNavigationStack: Bool { false }
}

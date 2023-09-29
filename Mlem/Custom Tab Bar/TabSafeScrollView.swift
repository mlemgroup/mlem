//
//  TabSafeScrollView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation
import SwiftUI

struct TabSafeScrollView: ViewModifier {
    func body(content: Content) -> some View {
        content
//            .safeAreaInset(edge: .bottom) {
//                Spacer()
//                    .frame(height: AppConstants.fancyTabBarHeight)
//            }
    }
}

extension View {
    /// Attach this modifier to a ScrollView to prevent it from not respecting the FancyTabBar's safeAreaInset
    @ViewBuilder
    func fancyTabScrollCompatible() -> some View {
        modifier(TabSafeScrollView())
    }
}

//
//  QuickSwitcherView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Foundation
import SwiftUI

struct QuickSwitcherView: View {
    var body: some View {
        Group {
            List {
                AccountListView(isQuickSwitcher: true)
            }
        }
        .hoistNavigation(.dismiss)
        .fancyTabScrollCompatible()
    }
}

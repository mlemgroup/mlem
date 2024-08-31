//
//  QuickSwitcherView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Foundation
import SwiftUI

struct QuickSwitcherView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        Form {
            AccountListView(isQuickSwitcher: true)
        }
        .onChange(of: scenePhase) {
            // when app moves into background, hide the account switcher. This prevents the app from reopening with the switcher presented.
            if scenePhase != .active, navigation.isTopSheet {
                navigation.dismissSheet()
            }
        }
        .presentationDetents([.medium, .large])
    }
}

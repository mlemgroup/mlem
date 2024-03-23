//
//  InboxRoot.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-20.
//

import Foundation
import SwiftUI

struct InboxRoot: View {
    @StateObject private var inboxRouter: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            NavigationStack(path: $inboxRouter.path) {
                InboxView()
                    .environmentObject(inboxRouter)
                    .tabBarNavigationEnabled(.inbox, navigation)
            }
            .environment(\.navigationPathWithRoutes, $inboxRouter.path)
            .environment(\.navigation, navigation)
            .environment(\.scrollViewProxy, scrollProxy)
            .handleLemmyLinkResolution(navigationPath: .constant(inboxRouter))
        }
    }
}

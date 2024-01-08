//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Foundation
import SwiftUI

struct FeedsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollViewReader { _ in
            NavigationSplitView {
                List {
                    NavigationLink(value: NewFeedType.all) {
                        Text("All Communities")
                    }
                    
                    NavigationLink(value: NewFeedType.local) {
                        Text("Local Communities")
                    }
                    
                    NavigationLink(value: NewFeedType.subscribed) {
                        Text("Subscribed Communities")
                    }
                    
                    NavigationLink(value: NewFeedType.saved) {
                        Text("Saved Posts")
                    }
                }
                .navigationDestination(for: NewFeedType.self) { feedType in
                    switch feedType {
                    case .all:
                        Text("This is the all feed!")
                    case .local:
                        Text("This is the local feed!")
                    case .subscribed:
                        Text("This is the subscribed feed!")
                    case .saved:
                        Text("This is the saved feed!")
                    }
                }
            } detail: {
                Text("Please select a community")
            }
        }
    }
}

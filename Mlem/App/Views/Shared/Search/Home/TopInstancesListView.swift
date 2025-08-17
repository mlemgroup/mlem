//
//  TopInstancesListView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-15.
//

import MlemMiddleware
import SwiftUI

struct TopInstancesListView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        FancyScrollView {
            LazyVStack(spacing: 0) {
                SearchResultsView(results: MlemStats.main.instances ?? []) { instance in
                    InstanceListRow(
                        instance,
                        readout: .users,
                        visitContext: .other
                    )
                }
                EndOfFeedView(loadingState: .done, viewType: .hobbit)
            }
            .animation(.easeOut(duration: 0.1), value: MlemStats.main.instances?.isEmpty)
        }
        .background(.themedGroupedBackground)
        .navigationTitle("Instances")
    }
}

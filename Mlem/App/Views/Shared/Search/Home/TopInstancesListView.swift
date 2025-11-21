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
            if let errorDetails = MlemStats.main.errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                content
            }
        }
        .background(.themedGroupedBackground)
        .navigationTitle("Instances")
    }

    var content: some View {
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
}

//
//  ModlogView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-25.
//

import MlemMiddleware
import SwiftUI

struct ModlogView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    
    let community: AnyCommunity?
    
    @State var entries: [ModlogEntry] = []
    
    var body: some View {
        Group {
            if let community {
                ContentLoader(model: community) { proxy in
                    content(community: proxy.entity)
                }
            } else {
                content(community: nil)
            }
        }
        .navigationTitle("Modlog")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func content(community: (any Community)?) -> some View {
        ScrollView {
            LazyVStack(spacing: Constants.main.standardSpacing) {
                ForEach(Array(entries.enumerated()), id: \.offset) { _, entry in
                    ModlogEntryView(entry: entry, targetCommunity: community)
                }
            }
            .padding([.horizontal, .bottom], Constants.main.standardSpacing)
        }
        .background(palette.groupedBackground)
        .onAppear {
            Task { @MainActor in
                do {
                    entries = try await appState.firstApi.getModlog(communityId: community?.id, type: .adminPurgePerson)
                } catch {
                    handleError(error)
                }
            }
        }
    }
}

//
//  ModlogView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-10.
//

import Dependencies
import Foundation
import SwiftUI

struct ModlogView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    // TODO: 2.0 enable searching--search needs to be submitted against the instance that the modlog is fetched from to ensure that the communityId/moderatorId is locally correct, which is annoying right now but very easy in 2.0.
    
    // TODO: tracker
    let instance: URL?
    let community: CommunityModel?
    
    init(modlogLink: ModlogLink) {
        switch modlogLink {
        case .userInstance:
            self.instance = nil
            self.community = nil
        case let .instance(instance):
            self.instance = instance
            self.community = nil
        case let .community(community):
            self.instance = nil
            self.community = community
        }
    }
    
    // TODO: tracker
    @State var modlogEntries: [ModlogEntry]?
    
    var body: some View {
        content
            .task {
                do {
                    modlogEntries = try await apiClient.getModlog(
                        for: instance,
                        communityId: community?.communityId
                    )
                } catch {
                    errorHandler.handle(error)
                }
            }
            .navigationTitle("Modlog")
            .hoistNavigation()
            .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            if let modlogEntries {
                if modlogEntries.isEmpty {
                    Text("No modlog entries")
                }
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    Divider()
                    
                    ForEach(modlogEntries, id: \.hashValue) { entry in
                        ModlogEntryView(modlogEntry: entry)
                        Divider()
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

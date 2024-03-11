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
    
    // TODO: let this pre-populate filters (e.g., user or community)
    let modlogLink: ModlogLink
    
    @State var modlogEntries: [AnyModlogEntry]?
    
    var body: some View {
        content
            .task {
                do {
                    modlogEntries = try await apiClient.getModlog()
                } catch {
                    errorHandler.handle(error)
                }
            }
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
                            .padding(AppConstants.standardSpacing)
                        Divider()
                    }
                }
            } else {
                Text("Loading...")
            }
        }
    }
}

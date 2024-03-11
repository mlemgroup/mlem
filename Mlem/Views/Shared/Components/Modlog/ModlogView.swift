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
    }
    
    @ViewBuilder
    var content: some View {
        ScrollView {
            if let modlogEntries {
                if modlogEntries.isEmpty {
                    Text("No modlog entries")
                }
                
                VStack(alignment: .leading, spacing: 0) {
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

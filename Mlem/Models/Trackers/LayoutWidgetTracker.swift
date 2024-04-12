//
//  LayoutWidgetTracker.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2023.
//

import Dependencies
import Foundation

struct LayoutWidgetGroups: Codable {
    var post: [LayoutWidgetType]
    var comment: [LayoutWidgetType]
    var moderator: [LayoutWidgetType]
}

extension LayoutWidgetGroups {
    init() {
        self.post = [.scoreCounter, .infoStack, .save, .reply]
        self.comment = [.scoreCounter, .infoStack, .save, .reply]
        self.moderator = [.resolve, .remove, .infoStack, .ban, .purge]
    }
}

@MainActor
class LayoutWidgetTracker: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published var groups: LayoutWidgetGroups = .init()
    
    init() {
        self.groups = persistenceRepository.loadLayoutWidgets()
    }
    
    func saveLayoutWidgets() {
        Task {
            try await persistenceRepository.saveLayoutWidgets(groups)
        }
    }
}

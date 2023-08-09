//
//  LayoutWidgetTracker.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2023.
//

import Foundation
import Dependencies

struct LayoutWidgetGroups: Codable {
    var post: [LayoutWidgetType]
    var comment: [LayoutWidgetType]
}

extension LayoutWidgetGroups {
    init() {
        self.post = [.scoreCounter, .infoStack, .save, .reply]
        self.comment = [.scoreCounter, .infoStack, .save, .reply]
    }
}

@MainActor
class LayoutWidgetTracker: ObservableObject {
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published var groups: LayoutWidgetGroups = .init()
    
    init() {
        groups = persistenceRepository.loadLayoutWidgets()
    }
    
    func saveLayoutWidgets() {
        Task {
            try await persistenceRepository.saveLayoutWidgets(groups)
        }
    }
}

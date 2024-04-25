//
//  LayoutWidgetTracker.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2023.
//

import Dependencies
import Foundation

struct LayoutWidgetGroups {
    var post: [LayoutWidgetType]
    var comment: [LayoutWidgetType]
    var moderator: [LayoutWidgetType]
}

extension LayoutWidgetGroups: Codable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.post = (try? values.decode([LayoutWidgetType].self, forKey: .post)) ?? LayoutWidgetType.defaultPostWidgets
        self.comment = (try? values.decode([LayoutWidgetType].self, forKey: .comment)) ?? LayoutWidgetType.defaultCommentWidgets
        self.moderator = (try? values.decode([LayoutWidgetType].self, forKey: .moderator)) ?? LayoutWidgetType.defaultModeratorWidgets
    }
}

extension LayoutWidgetGroups {
    init() {
        self.post = LayoutWidgetType.defaultPostWidgets
        self.comment = LayoutWidgetType.defaultCommentWidgets
        self.moderator = LayoutWidgetType.defaultModeratorWidgets
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

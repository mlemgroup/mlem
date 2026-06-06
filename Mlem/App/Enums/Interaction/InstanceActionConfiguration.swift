//
//  InstanceActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-05-29.
//

import Actions
import Foundation

struct InstanceActionConfiguration: Codable, ContextMenuConfiguration, SwipeActionConfiguration {
    var savedSwipes: ActionSeedSwipeConfiguration?
    var savedContextMenu: [ActionSeed]?

    static var availableActions: ActionSeedSections { .init(sections: [
            [
                .visit,
                .logIn,
                .signUp,
                .openInBrowser,
                .share,
                .block
            ]
        ])
    }

    static var defaultSwipes: ActionSeedSwipeConfiguration {
        .init(leading: [], trailing: [])
    }

    static var defaultContextMenu: [ActionSeed] {
        [
            .visit,
            .logIn,
            .signUp,
            .share,
            .block
        ]
    }

    enum CodingKeys: CodingKey {
        case swipes
    }

    init() {
        self.savedSwipes = nil
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let swipeConfigurationContainer = try? container.nestedContainer(
            keyedBy: ActionSeedSwipeConfiguration.CodingKeys.self,
            forKey: .swipes
        )
        if let swipeConfigurationContainer {
            self.savedSwipes = try .init(from: swipeConfigurationContainer, availableActions: Self.availableActions.all)
        } else {
            self.savedSwipes = nil
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.savedSwipes, forKey: .swipes)
    }
}

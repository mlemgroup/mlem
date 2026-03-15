//
//  CommunityActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import Foundation

struct CommunityActionConfiguration: Codable, SwipeActionConfiguration {
    var savedSwipes: ActionSeedSwipeConfiguration?

    static var availableActions: ActionSeedSections { .init(sections: [
            [
                .newPost,
                .subscribe,
                .favorite,
                .goToInstance,
                .copyName,
                .share
            ],
            [
                .block,
                .remove,
                .purge
            ]
        ])
    }

    static var defaultSwipes: ActionSeedSwipeConfiguration {
        .init(leading: [], trailing: [.subscribe, .favorite])
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

//
//  CommunityActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import Foundation

struct CommunityActionConfiguration: Codable {
    private let swipes_: ActionSeedSwipeConfiguration?

    var swipes: ActionSeedSwipeConfiguration {
        swipes_ ?? Self.defaultSwipes
    }

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
        self.swipes_ = nil
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let swipeConfigurationContainer = try? container.nestedContainer(
            keyedBy: ActionSeedSwipeConfiguration.CodingKeys.self,
            forKey: .swipes
        )
        if let swipeConfigurationContainer {
            self.swipes_ = try .init(from: swipeConfigurationContainer, availableActions: Self.availableActions.all)
        } else {
            self.swipes_ = nil
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.swipes_, forKey: .swipes)
    }
}

struct ActionSeedSwipeConfiguration: Encodable {
    let leading: [ActionSeed]   
    let trailing: [ActionSeed]

    enum CodingKeys: CodingKey {
        case leading, trailing
    }
}

extension ActionSeedSwipeConfiguration {
    init(from container: KeyedDecodingContainer<CodingKeys>, availableActions: [ActionSeed]) throws {
        let leading = try container.decode([String].self, forKey: .leading) 
        self.leading = leading.compactMap { key in availableActions.first(where: {$0.key == key}) }
        let trailing = try container.decode([String].self, forKey: .trailing) 
        self.trailing = trailing.compactMap { key in availableActions.first(where: {$0.key == key}) }
    }
}

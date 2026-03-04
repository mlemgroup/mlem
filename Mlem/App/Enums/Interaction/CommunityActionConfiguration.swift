//
//  CommunityActionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import Foundation

struct CommunityActionConfiguration: Codable {
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
}

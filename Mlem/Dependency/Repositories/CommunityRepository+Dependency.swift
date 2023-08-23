//
//  CommunityRepository+Dependency.swift
//  Mlem
//
//  Created by mormaer on 27/07/2023.
//
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

extension CommunityRepository: DependencyKey {
    static var liveValue = CommunityRepository()
    
    static var previewValue = CommunityRepository(
        subscriptions: { _ in
            ["Science", "Technology", "World News", "Music", "Memes", "Aww", "Gaming"]
                .enumerated()
                .map { index, name -> APICommunityView in
                    .mock(
                        community: .mock(
                            id: index,
                            name: name
                        ),
                        subscribed: .subscribed
                    )
                }
        },
        details: { _, id in
            .mock(
                communityView: .mock(
                    community: .mock(
                        id: id
                    )
                )
            )
        },
        updateSubscription: { _, id, subscribed in
            .mock(
                community: .mock(
                    id: id
                ),
                subscribed: subscribed ? .subscribed : .notSubscribed,
                blocked: false,
                counts: .mock()
            )
        },
        hideCommunity: { _, id, _ in
            .mock(
                communityView: .mock(
                    community: .mock(
                        id: id,
                        hidden: true
                    )
                )
            )
        },
        unhideCommunity: { _, id in
            .mock(
                communityView: .mock(
                    community: .mock(
                        id: id,
                        hidden: false
                    )
                )
            )
        },
        blockCommunity: { _, id in
            .mock(
                communityView: .mock(
                    community: .mock(
                        id: id
                    )
                ),
                blocked: true
            )
        },
        unblockCommunity: { _, id in
            .mock(
                communityView: .mock(
                    community: .mock(
                        id: id
                    )
                ),
                blocked: false
            )
        }
    )
    
    static var testValue = CommunityRepository(
        subscriptions: unimplemented("CommunityRepository.subscriptions"),
        details: unimplemented("CommunityRepository.details"),
        updateSubscription: unimplemented("CommunityRepository.updateSubscription"),
        hideCommunity: unimplemented("CommunityRepository.hideCommunity"),
        unhideCommunity: unimplemented("CommunityRepository.unhideCommunity"),
        blockCommunity: unimplemented("CommunityRepository.blockCommunity"),
        unblockCommunity: unimplemented("CommunityRepository.unblockCommunity")
    )
}

extension DependencyValues {
    var communityRepository: CommunityRepository {
        get { self[CommunityRepository.self] }
        set { self[CommunityRepository.self] = newValue }
    }
}

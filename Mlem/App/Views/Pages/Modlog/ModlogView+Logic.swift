//
//  ModlogView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-11.
//

import MlemMiddleware
import SwiftUI

extension ModlogView {
    enum InitialTarget: Hashable {
        case community(AnyCommunity)
        case instance(InstanceHashWrapper)
        
        var communityValue: (any CommunityStubProviding)? {
            switch self {
            case let .community(community): community.wrappedValue
            default: nil
            }
        }
        
        var instanceValue: (any InstanceStubProviding)? {
            switch self {
            case let .instance(instance): instance.wrappedValue
            default: nil
            }
        }
    }
    
    func refresh() async throws {
        let api: ApiClient
        switch targetFilter {
        case let .instance(instance):
            guard let url = instance.url else {
                assertionFailure()
                throw ApiClientError.unsuccessful
            }
            if AppState.main.firstApi.host == url.host {
                api = AppState.main.firstApi
            } else {
                api = .getApiClient(for: url, with: nil)
            }
        default:
            api = AppState.main.firstApi
        }
        print("API", api)
        try await feedLoader.refresh(
            api: api,
            communityId: targetFilter?.communityValue?.id,
            clearBeforeRefresh: true
        )
    }
}

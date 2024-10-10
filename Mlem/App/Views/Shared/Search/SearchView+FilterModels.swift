//
//  SearchView+FilterModels.swift
//  Mlem
//
//  Created by Sjmarf on 04/10/2024.
//

import MlemMiddleware
import SwiftUI

extension SearchView {
    enum InstanceFilter: Hashable {
        case any, local, other(InstanceSummary)
        
        var label: String {
            switch self {
            case .any: .init(localized: "Any Instance")
            case .local: AppState.main.firstApi.host ?? .init(localized: "Local")
            case let .other(instance): instance.host
            }
        }
        
        var isOther: Bool {
            switch self {
            case .other: true
            default: false
            }
        }
    }
    
    enum LocationFilter: Hashable {
        case any, subscribed, moderated, localInstance, instance(InstanceSummary), community(Community2)
        
        var label: String {
            switch self {
            case .any:
                .init(localized: "Anywhere")
            case .subscribed:
                .init(localized: "Subscribed")
            case .moderated:
                .init(localized: "Moderated")
            case .localInstance:
                AppState.main.firstApi.host ?? "Local"
            case let .instance(instance):
                instance.host
            case let .community(community):
                community.name
            }
        }
        
        var systemImage: String {
            switch self {
            case .any: Icons.websiteIcon
            case .subscribed: Icons.subscribedFeed
            case .moderated: Icons.moderation
            case .localInstance, .instance: Icons.instance
            case .community: Icons.community
            }
        }
        
        var isInstance: Bool {
            switch self {
            case .instance: true
            default: false
            }
        }
        
        var instanceStub: InstanceStub? {
            if case let .instance(instance) = self {
                return instance.instanceStub?.asLocal()
            }
            return nil
        }
        
        var isCommunity: Bool {
            switch self {
            case .community: true
            default: false
            }
        }
    }
    
    @Observable
    class CommunityFilters {
        var sort: ApiSortType = .topAll
        var instance: InstanceFilter = .any
    }
    
    @Observable
    class PersonFilters {
        var sort: ApiSortType = .topAll
        var instance: InstanceFilter = .any
    }
    
    @Observable
    class InstanceFilters {
        var sort: InstanceSort = .score
    }
    
    @Observable
    class PostFilters {
        var sort: ApiSortType = .topAll
        var creator: Person2?
        var location: LocationFilter = .any
    }
}

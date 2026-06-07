//
//  SearchView+FilterModels.swift
//  Mlem
//
//  Created by Sjmarf on 04/10/2024.
//

import Icons
import MlemBackend
import MlemMiddleware
import SwiftUI

extension SearchView {
    enum InstanceFilter: Hashable {
        case any, local, other(InstanceSummary)
        
        var label: String {
            switch self {
            case .any: .init(localized: "Any Instance")
            case .local: AppState.main.firstApi.host
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
        case any, subscribed, moderated, localInstance, instance(InstanceSummary), community(Community)
        
        var label: String {
            switch self {
            case .any:
                .init(localized: "Anywhere")
            case .subscribed:
                .init(localized: "Subscribed")
            case .moderated:
                .init(localized: "Moderated")
            case .localInstance:
                AppState.main.firstApi.host
            case let .instance(instance):
                instance.host
            case let .community(community):
                community.name
            }
        }
        
        var icon: Icon {
            switch self {
            case .any: .general.website
            case .subscribed: .lemmy.subscribedFeed
            case .moderated: .lemmy.moderation
            case .localInstance, .instance: .lemmy.instance
            case .community: .lemmy.community
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
                return instance.instanceStub.asLocal()
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
        var sort: CommunitySortType
        var instance: InstanceFilter = .any

        private let defaultSort: CommunitySortType

        var isDefault: Bool { sort == defaultSort }

        init(software: SiteSoftware) {
            let sort = CommunitySortType.default(software: software)
            self.sort = sort
            self.defaultSort = sort
        }
    }
    
    @Observable
    class PersonFilters {
        var sort: SearchSortType
        var instance: InstanceFilter = .any

        private let defaultSort: SearchSortType

        var isDefault: Bool { sort == defaultSort }
        
        init(software: SiteSoftware) {
            let sort: SearchSortType

            if software.supports(.searchSortType(.top(.allTime))) {
                sort = .top(.allTime)
            } else {
                sort = .top(.limited(.month))
            }

            self.sort = sort
            self.defaultSort = sort
        }
    }
    
    @Observable
    class InstanceFilters {
        var sort: InstanceSort = .score
    }
    
    @Observable
    class PostFilters {
        var sort: PostSortType
        var creator: Person?
        var location: LocationFilter = .any
        
        init(software: SiteSoftware) {
            if software.supports(.searchSortType(.top(.allTime))) {
                self.sort = .top(.allTime)
            } else {
                self.sort = .top(.limited(.month))
            }
        }
    }
    
    @Observable
    class CommentFilters {
        var sort: CommentSortType = .top(.allTime)
        var creator: Person?
        var location: LocationFilter = .any
    }
}

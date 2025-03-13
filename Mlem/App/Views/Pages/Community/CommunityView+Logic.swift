//
//  CommunityView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-12.
//

import Foundation
import MlemMiddleware

extension CommunityView {
    func openAddModSheet() {
        navigation.openSheet(.personPicker { person in
            newMod = person
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingConfirmation = true
            }
        })
    }
    
    func addNewMod() {
        guard let newMod else {
            assertionFailure("newMod cannot be nil")
            return
        }
        
        guard let community = community.wrappedValue as? any Community else {
            assertionFailure("Community not loaded yet")
            return
        }

        Task {
            do {
                try await community.addModerator(newMod, added: true)
            } catch {
                handleError(error)
            }
        }
    }
    
    func moderatorQuickSwipes(community: any Community, person: any Person) -> SwipeConfiguration {
        guard let community = community as? any Community3Providing,
              let myPerson = appState.firstPerson,
              myPerson.canModerate(person, in: community) else {
            return .init()
        }
        
        return .init(trailingActions: [person.addModAction(community: community, isOn: true)])
    }
    
    func setupFeedLoader(community: any Community) {
        if postFeedLoader == nil {
            Task { @MainActor in
                @Setting(\.internetSpeed) var internetSpeed
                @Setting(\.showReadInFeed) var showReadInFeed
                postFeedLoader = try await .init(
                    pageSize: internetSpeed.pageSize,
                    sortType: appState.initialFeedSortType,
                    showReadPosts: showReadInFeed,
                    filterContext: filtersTracker.filterContext,
                    prefetchingConfiguration: .forPostSize(postSize),
                    urlCache: Constants.main.urlCache,
                    community: community
                )
            }
        } else if postFeedLoader?.community.api != community.api {
            postFeedLoader?.community = community
        }
    }
    
    func logVisit(_ community: Community2) {
        if let session = (appState.firstSession as? UserSession), let visitHistory = session.visitHistory {
            guard session.api === community.api else { return }
            visitHistory.addCommunity(community, context: visitContext)
            Task(priority: .background) {
                try await session.saveVisitHistory()
            }
        }
    }
}

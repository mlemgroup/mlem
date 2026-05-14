//
//  CommunityView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-12.
//

import Foundation
import MlemMiddleware
import QuickSwipes

extension CommunityView {
    func canEditModeratorList(_ community: Community) -> Bool {
        guard let firstPerson = appState.firstPerson else { return false }
        if !firstPerson.api.supports(.editModeratorList, defaultValue: true) {
            return false
        }
        return (firstPerson.isAdmin.value ?? false) || (firstPerson.moderates?(.community(community)) ?? false)
    }

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

        Task {
            do {
                try await community.addModerator(newMod, added: true)
            } catch {
                handleError(error)
            }
        }
    }
    
    func moderatorQuickSwipes(community: Community, person: Person) -> SwipeConfiguration {
        guard let communityModerators = community.moderators.value,
              canEditModeratorList(community),
              let myPerson = appState.firstPerson,
              myPerson.canModerate(person, communityModerators: communityModerators) else {
            return .init()
        }
        
        return .init(trailingActions: [person.addModAction(community: community, isOn: true)], leadingBuffer: 70)
    }
    
    func setupFeedLoader(community: Community) {
        if postFeedLoader == nil {
            Task { @MainActor in
                @Setting(\.behavior_internetSpeed) var internetSpeed
                @Setting(\.feed_showRead) var showReadInFeed
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
    
    func logVisit(_ community: Community) {
        if let session = (appState.firstSession as? UserSession), let visitHistory = session.visitHistory {
            guard session.api === community.api else { return }
            visitHistory.addCommunity(community, context: visitContext)
            Task(priority: .background) {
                try await session.saveVisitHistory()
            }
        }
    }
}

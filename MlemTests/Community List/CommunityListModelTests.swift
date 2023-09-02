//
//  CommunityListModelTests.swift
//  MlemTests
//
//  Created by mormaer on 13/08/2023.
//
//

@testable import Mlem

import Dependencies
import XCTest

final class CommunityListModelTests: XCTestCase {
    private let account: SavedAccount = .mock()
    
    override func setUpWithError() throws {
        favoritesData = Data()
    }
    
    override func tearDownWithError() throws {}
    
    func testInitialState() async throws {
        // set some favorites data
        favoritesData = try JSONEncoder().encode([
            FavoriteCommunity(forAccountID: account.id, community: .mock(id: 42))
        ])
        
        let model = withDependencies {
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // return a subscription for the user
                [.mock(community: .mock(id: 0), subscribed: .subscribed)]
            }
        } operation: {
            CommunityListModel()
        }
        
        // assert that even though a subscription and favorite are available nothing is present without `load()` being called
        XCTAssert(model.communities.isEmpty)
    }
    
    func testLoadingWithNoSubscriptionsOrFavourites() async throws {
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = favoritesTracker
            // return an empty array from the the community repository to indicate the user has no subscriptions
            $0.communityRepository.subscriptions = { _ in [] }
        } operation: {
            CommunityListModel()
        }
        
        // ask the model to load
        await model.load()
        // assert after loading it's empty as there are no subscriptions or favourites for this user
        XCTAssert(model.communities.isEmpty)
    }
    
    func testLoadingWithSubscriptionAndFavorite() async throws {
        // set some favorites data
        favoritesData = try JSONEncoder().encode([
            FavoriteCommunity(forAccountID: account.id, community: .mock(id: 42, name: "favorite community"))
        ])
        
        let subscription = APICommunityView.mock(community: .mock(id: 0, name: "subscribed community"), subscribed: .subscribed)
        
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // provide a subscription for the user
                [subscription]
            }
        } operation: {
            CommunityListModel()
        }
        
        // ask the modek to load
        await model.load()
        
        // assert both the favorite and subscription are present in the model
        XCTAssert(model.communities.count == 2)
        XCTAssert(model.communities[0].name == "favorite community")
        XCTAssert(model.communities[1].name == "subscribed community")
    }
    
    func testDuplicatesAreHandledCorrectly() async throws {
        let community: APICommunity = .mock(id: 42)
        
        // set the above community as our only favorite
        favoritesData = try JSONEncoder().encode([
            FavoriteCommunity(forAccountID: account.id, community: community)
        ])
        
        // use the same community as our only subscriptiom
        let subscription = APICommunityView.mock(community: community, subscribed: .subscribed)
        
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // provide a subscription for the user
                [subscription]
            }
        } operation: {
            CommunityListModel()
        }
        
        // ask the model to load
        await model.load()
        // expectation is that although we will load the same community in favorites and subscriptions
        // when the two lists combine the duplicate will be excluded, leaving only one copy of it
        XCTAssert(model.communities.count == 1)
        XCTAssert(model.communities[0].id == 42)
    }
    
    func testSubscribedStatusIsCorrect() async throws {
        let communityView: APICommunityView = .mock(
            community: .mock(id: 42),
            subscribed: .subscribed
        )
        
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = favoritesTracker
            // return a single community under subscriptions for this test
            $0.communityRepository.subscriptions = { _ in [communityView] }
        } operation: {
            CommunityListModel()
        }
        
        // ask the model to load
        await model.load()
        // assert only one subscription is present
        XCTAssert(model.communities.count == 1)
        // assert the model correctly identfies if we're subscribed
        XCTAssert(model.isSubscribed(to: communityView.community))
        // assert the model correctly identifies when we're not subscribed by passing a different community
        XCTAssertFalse(model.isSubscribed(to: .mock(id: 24)))
    }
    
    func testSuccessfulSubscriptionUpdate() async throws {
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.notifier = Notifier(display: { _ in /* ignore notifications in this test */ })
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // return no subscriptions
                []
            }
            // when asked to update the remote subscription return successfully
            $0.communityRepository.updateSubscription = { _, communityId, subscribed in
                APICommunityView.mock(community: .mock(id: communityId), subscribed: subscribed ? .subscribed : .notSubscribed)
            }
        } operation: {
            CommunityListModel()
        }
        
        // load the model
        await model.load()
        // assert we have a blank slate
        XCTAssert(model.communities.isEmpty)
        // tell the model to subscribe to a community
        model.updateSubscriptionStatus(for: .mock(id: 42), subscribed: true)
        // assert it is _immediately_ added to the communities (state faking)
        XCTAssert(model.communities.count == 1)
        XCTAssert(model.communities[0].id == 42)
        // allow suspension so the model can make the remote call (stubbed as `.updateSubscription` above)
        await Task.megaYield(count: 1000)
        // assert the community remains in our list as the _remote_ call succeeded
        XCTAssert(model.communities.count == 1)
        XCTAssert(model.communities[0].id == 42)
    }
    
    func testFailedSubscriptionUpdate() async throws {
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.errorHandler = MockErrorHandler(didReceiveError: { _ in /* ignore the returned error */ })
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // return no subscriptions
                []
            }
            // when asked to update the remote subscription throw an error
            $0.communityRepository.updateSubscription = { _, _, _ in
                throw APIClientError.cancelled
            }
        } operation: {
            CommunityListModel()
        }
        
        // load the model
        await model.load()
        // assert we have a blank slate
        XCTAssert(model.communities.isEmpty)
        // tell the model to subscribe to a community
        model.updateSubscriptionStatus(for: .mock(id: 42), subscribed: true)
        // assert it is _immediately_ added to the communities (state faking)
        XCTAssert(model.communities.count == 1)
        XCTAssert(model.communities[0].id == 42)
        // allow suspension so the model can make the remote call (stubbed as `.updateSubscription` above)
        await Task.megaYield(count: 1000)
        // assert the community has been removed from our list as the _remote_ call failed in this test
        XCTAssert(model.communities.isEmpty)
    }
    
    func testModelRespondsToFavorites() async throws {
        // hold on to our tracker in this test so we can exercise it's methods
        let tracker = favoritesTracker
        
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = tracker
            // return an empty array from the the community repository to indicate the user has no subscriptions
            $0.communityRepository.subscriptions = { _ in [] }
        } operation: {
            CommunityListModel()
        }

        // ask the model to load
        await model.load()
        // assert the model is not displaying any favorites
        XCTAssertFalse(model.visibleSections.contains(where: { $0.viewId == "favorites" }))
        // add a favorite to the tracker, expectation is the model will observe this change and update itself
        let favoriteCommunity = APICommunity.mock(id: 42)
        tracker.favorite(favoriteCommunity)
        // assert that adding this favorite resulted in the model updating, it should now display a favorites section
        XCTAssert(model.visibleSections.contains(where: { $0.viewId == "favorites" }))
        XCTAssert(model.communities.first! == favoriteCommunity)
        // now unfavorite the community
        tracker.unfavorite(favoriteCommunity)
        // assert that the favorites section is no longer included
        XCTAssertFalse(model.visibleSections.contains(where: { $0.viewId == "favorites" }))
    }
    
    func testCorrectCommunitiesAreReturnedForSections() async throws {
        let communities: [APICommunityView] = [
            .mock(community: .mock(id: 0, name: "accordion")),
            .mock(community: .mock(id: 1, name: "harp")),
            .mock(community: .mock(id: 2, name: "harmonica")),
            .mock(community: .mock(id: 3, name: "trombone")),
            .mock(community: .mock(id: 4, name: "xylophone")),
            .mock(community: .mock(id: 5, name: "glockenspiel")),
            .mock(community: .mock(id: 6, name: "tuba"))
        ]
        
        let model = withDependencies {
            $0.mainQueue = .immediate
            $0.favoriteCommunitiesTracker = favoritesTracker
            $0.communityRepository.subscriptions = { _ in
                // return our example communities from above ^
                communities
            }
        } operation: {
            CommunityListModel()
        }
        
        // ask the model to load
        await model.load()
        // assert all the communities are present
        XCTAssert(model.communities.count == communities.count)
        // assert we have the correct number of visible sections, some will group together...
        XCTAssert(model.visibleSections.count == 5)
        // assuming alphabetical ordering, assert we get the correct communities back for each section
        XCTAssertEqual(
            // section 0 (aka 'A') should include 'accordion'
            model.communities(for: model.visibleSections[0]),
            [communities[0].community]
        )
        XCTAssertEqual(
            // section 1 (aka 'G') should include 'glockenspiel'
            model.communities(for: model.visibleSections[1]),
            [communities[5].community]
        )
        XCTAssertEqual(
            // section 2 (aka 'H') should include 'harmonica' and 'harp'
            model.communities(for: model.visibleSections[2]),
            [communities[2].community, communities[1].community]
        )
        XCTAssertEqual(
            // section 3 (aka 'T') should include 'trombone' and 'tuba'
            model.communities(for: model.visibleSections[3]),
            [communities[3].community, communities[6].community]
        )
        XCTAssertEqual(
            // section 4 (aka 'X') should include 'xylophone'
            model.communities(for: model.visibleSections[4]),
            [communities[4].community]
        )
    }
    
    func testAllSectionsOrder() async throws {
        let model = withDependencies {
            $0.favoriteCommunitiesTracker = favoritesTracker
        } operation: {
            CommunityListModel()
        }
        
        // expectation is the all sections are made up of:
        // - top section
        // - favorites
        // - alphabetics (a-z)
        // - non-letter (symbols/numerics)
        
        // assert we have 26 for alphabet + 3
        XCTAssert(model.allSections().count == 29)
        // assert order
        XCTAssert(model.allSections()[0].viewId == "top")
        XCTAssert(model.allSections()[1].viewId == "favorites")
        
        let alphabet: [String] = .alphabet
        let offset = 2
        alphabet.enumerated().forEach { index, character in
            XCTAssert(model.allSections()[index + offset].viewId == character)
        }
        XCTAssert(model.allSections()[28].viewId == "non_letter_titles")
    }
    
    // MARK: - Helpers
    
    var favoritesData = Data()
    
    var favoritesTracker: FavoriteCommunitiesTracker {
        withDependencies {
            $0.persistenceRepository = .init(
                keychainAccess: unimplemented(),
                read: { _ in self.favoritesData },
                write: { data, _ in self.favoritesData = data }
            )
        } operation: {
            let tracker = FavoriteCommunitiesTracker()
            tracker.configure(for: account)
            return tracker
        }
    }
}

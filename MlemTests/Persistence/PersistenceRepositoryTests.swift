//
//  PersistenceRepositoryTests.swift
//  MlemTests
//
//  Created by mormaer on 05/08/2023.
//
//

@testable import Mlem

import Dependencies
import XCTest

final class PersistenceRepositoryTests: XCTestCase {
    private enum PersistenceTestError: Error {
        case noDataForURL
    }
    
    private var repository: PersistenceRepository!
    private var disk = [URL: Data]()
    private var keychain = [String: String]()
    private var errors = [Error]()
    
    override func setUpWithError() throws {
        repository = withDependencies {
            $0.date.now = .now
            $0.errorHandler = MockErrorHandler { self.errors.append($0) }
        } operation: {
            PersistenceRepository(
                keychainAccess: { self.keychain[$0] },
                read: { url in
                    guard let data = self.disk[url] else {
                        throw PersistenceTestError.noDataForURL
                    }
                    
                    return data
                },
                write: { self.disk[$1] = $0 },
                bundle: Bundle(for: type(of: self))
            )
        }

        disk = [:]
        keychain = [:]
        errors = []
    }

    override func tearDownWithError() throws {}

    // MARK: Accounts
    
    func testSaveAccounts() async throws {
        let accounts: [SavedAccount] = [
            .init(id: 0, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_0", username: "User0"),
            .init(id: 1, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_1", username: "User1")
        ]
        
        XCTAssert(disk.keys.isEmpty) // confirm we have a blank slate
        try await repository.saveAccounts(accounts) // save our test accounts
        
        // now get the accounts back _without_ using the `.loadAccounts` method
        // there is some keychain related logic done by the `.loadAccounts` method
        // which this test is not checking, we just want to assert the data was written to disk
        
        let accountsFromDisk = try load([SavedAccount].self)
        XCTAssertEqual(accountsFromDisk, accounts) // confirm what we saved is what we got back
    }
    
    func testSecureTokensAreNotWrittenToDisk() async throws {
        let accounts: [SavedAccount] = [
            .init(id: 0, instanceLink: URL(string: "https://mlem.group")!, accessToken: "ultra_secret_token", username: "User0")
        ]
        
        try await repository.saveAccounts(accounts)
        
        let accountFromDisk = try load([SavedAccount].self).first
        
        XCTAssert(accountFromDisk!.accessToken == "redacted") // confirm `redacted` instead of the original token was written to disk
    }
    
    func testLoadAccounts() async throws {
        let accounts: [SavedAccount] = [
            .init(id: 0, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_0", username: "User0"),
            .init(id: 1, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_1", username: "User1")
        ]
        
        // as we are testing the `.loadAccounts` method, we need to supply tokens
        
        keychain["0_accessToken"] = "a_mock_token_0"
        keychain["1_accessToken"] = "a_mock_token_1"
        
        try await repository.saveAccounts(accounts)
        let loadedAccounts = repository.loadAccounts()
        
        // assert we got back the same accounts
        XCTAssertEqual(accounts, loadedAccounts)
        
        // assert the accounts were correctly associated with the tokens in the keychain
        XCTAssertEqual(loadedAccounts[0].accessToken, "a_mock_token_0")
        XCTAssertEqual(loadedAccounts[1].accessToken, "a_mock_token_1")
    }
    
    func testAccountsWithoutTokensAreOmitted() async throws {
        let accounts: [SavedAccount] = [
            .init(id: 0, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_0", username: "User0"),
            .init(id: 1, instanceLink: URL(string: "https://mlem.group")!, accessToken: "token_1", username: "User1")
        ]
        
        // only provide a token for the first account in this test
        keychain["0_accessToken"] = "a_mock_token_0"
        
        try await repository.saveAccounts(accounts)
        let loadedAccounts = repository.loadAccounts()
        
        XCTAssert(loadedAccounts.count == 1) // assert only one of the accounts was returned
        XCTAssert(loadedAccounts.first! == accounts.first!) // assert it was the correct account
        XCTAssert(loadedAccounts.first!.accessToken == "a_mock_token_0") // assert it's token was correctly injected
    }
    
    // MARK: - Recent Searches
    
    func testSaveRecentSearches() async throws {
        let searches: [ContentModelIdentifier] = [.init(contentType: .user, contentId: 1), .init(contentType: .community, contentId: 2)]
        
        try await repository.saveRecentSearches(for: 1, with: searches) // write the examples to disk
        let searchesFromDisk = try load([Int: [ContentModelIdentifier]].self) // load them from the disk _without_ using the repository
        
        let expected: [Int: [ContentModelIdentifier]] = [1: searches]
        XCTAssertEqual(expected, searchesFromDisk) // confirm what was written to disk matches what we sent in
    }
    
    func testLoadRecentSearchesWithValues() async throws {
        let searches1: [ContentModelIdentifier] = [.init(contentType: .user, contentId: 1), .init(contentType: .community, contentId: 2)]
        let searches2: [ContentModelIdentifier] = [.init(contentType: .user, contentId: 2), .init(contentType: .community, contentId: 3)]
        
        try await repository.saveRecentSearches(for: 1, with: searches1)
        try await repository.saveRecentSearches(for: 2, with: searches2)
        
        let loadedSearches1 = repository.loadRecentSearches(accountHash: 1) // read them back
        let loadedSearches2 = repository.loadRecentSearches(accountHash: 2)
        
        XCTAssertEqual(loadedSearches1, searches1) // assert we were given the same values back
        XCTAssertEqual(loadedSearches2, searches2)
    }
    
    func testLoadRecentSearchesWithoutValues() async throws {
        XCTAssert(disk.isEmpty) // assert that our mock disk has nothing in it
        let loadedSearches = repository.loadRecentSearches(accountHash: 1) // perform a load knowing the disk is empty
        XCTAssert(loadedSearches.isEmpty) // assert we were returned an empty list
    }
    
    // MARK: - Favorite Communities
    
    func testSaveFavoriteCommunities() async throws {
        let communities: [FavoriteCommunity] = [.init(forAccountID: 0, community: .mock())]
        
        try await repository.saveFavoriteCommunities(communities) // write the examples to disk
        let communitiesFromDisk = try load([FavoriteCommunity].self) // load them from the disk _without_ using the repository
        
        XCTAssertEqual(communities, communitiesFromDisk) // confirm what was written to disk matches what we sent in
    }
    
    func testLoadFavoriteCommunitiesWithValues() async throws {
        let communities: [FavoriteCommunity] = [.init(forAccountID: 0, community: .mock())]
        
        try await repository.saveFavoriteCommunities(communities) // write the examples to disk
        let loadedCommunities = repository.loadFavoriteCommunities() // read them back
        
        XCTAssertEqual(loadedCommunities, communities) // assert we were given the same values back
    }
    
    func testLoadFavoriteCommunitiesWithoutValues() async throws {
        XCTAssert(disk.isEmpty) // assert that our mock disk has nothing in it
        let loadedCommunities = repository.loadFavoriteCommunities() // perform a load knowing the disk is empty
        XCTAssert(loadedCommunities.isEmpty) // assert we were returned an empty list
    }
    
    // MARK: - Easter Flags
    
    func testSaveEasterFlags() async throws {
        let flags: Set<EasterFlag> = [.login(host: .beehaw)]
        
        try await repository.saveEasterFlags(flags) // write the examples to disk
        let flagsFromDisk = try load(Set<EasterFlag>.self) // load them from the disk _without_ using the repository
        
        XCTAssertEqual(flags, flagsFromDisk) // confirm what was written to disk matches what we sent in
    }
    
    func testLoadEasterFlagsWithValues() async throws {
        let flags: Set<EasterFlag> = [.login(host: .beehaw)]
        
        try await repository.saveEasterFlags(flags) // write the examples to disk
        let loadedFlags = repository.loadEasterFlags() // read them back
        
        XCTAssertEqual(loadedFlags, flags) // assert we were given the same values back
    }
    
    func testLoadEasterFlagsWithoutValues() async throws {
        XCTAssert(disk.isEmpty) // assert that our mock disk has nothing in it
        let loadedFlags = repository.loadEasterFlags() // perform a load knowing the disk is empty
        XCTAssert(loadedFlags.isEmpty) // assert we were returned an empty set
    }
    
    // MARK: - Filtered Keywords
    
    func testSaveFilteredKeywords() async throws {
        let keywords = ["some", "example", "keywords"]
        
        try await repository.saveFilteredKeywords(keywords) // write the examples to disk
        let keywordsFromDisk = try load([String].self) // load them from the disk _without_ using the repository
        
        XCTAssertEqual(keywords, keywordsFromDisk) // confirm what was written to disk matches what we sent in
    }
    
    func testLoadKeywordsWithValues() async throws {
        let keywords = ["some", "example", "keywords"]
        
        try await repository.saveFilteredKeywords(keywords) // write the examples to disk
        let loadedKeywords = repository.loadFilteredKeywords() // read them back
        
        XCTAssertEqual(loadedKeywords, keywords) // assert we were given the same values back
    }
    
    func testLoadKeywordsWithoutValues() async throws {
        XCTAssert(disk.isEmpty) // assert that our mock disk has nothing in it
        let loadedKeywords = repository.loadFilteredKeywords() // perform a load knowing the disk is empty
        XCTAssert(loadedKeywords.isEmpty) // assert we were returned an empty set
    }
    
    func testLoadLayoutWidgetsWithValues() async throws {
        let postWidgets: [LayoutWidgetType] = [.upvote, .downvote]
        let commentWidgets: [LayoutWidgetType] = [.reply, .share]
        let widgets = LayoutWidgetGroups(post: postWidgets, comment: commentWidgets)
        
        try await repository.saveLayoutWidgets(widgets) // write the examples to disk
        let loadedWidgets = repository.loadLayoutWidgets() // read them back
        
        // assert we were given the same values back
        XCTAssertEqual(loadedWidgets.post, postWidgets)
        XCTAssertEqual(loadedWidgets.comment, commentWidgets)
    }
    
    func testLoadLayoutWidgetsWithoutValues() async throws {
        XCTAssert(disk.isEmpty) // assert that our mock disk has nothing in it
        let loadedWidgets = repository.loadLayoutWidgets() // perform a load knowing the disk is empty
        
        // expected behaviour is to recieve the `default` state
        let defaultState = LayoutWidgetGroups()
        // assert each loaded group matches the default state
        XCTAssertEqual(loadedWidgets.post, defaultState.post)
        XCTAssertEqual(loadedWidgets.comment, defaultState.comment)
    }
    
    func testLoadInstanceMetadataWithValues() async throws {
        let metadata: [InstanceMetadata] = [
            .mock(url: .mock.appending(path: "/example1")),
            .mock(url: .mock.appending(path: "/example2"))
        ]
        
        try await repository.saveInstanceMetadata(metadata) // write the examples to disk
        let loadedMetadata = repository.loadInstanceMetadata() // read them back
        
        // assert we were given the same values back
        XCTAssertEqual(loadedMetadata.value, metadata)
    }
    
    func testLoadInstanceMetadataWithoutValues() async throws {
        let bundledFile = try bundledMetadata
        // assert that our mock disk has nothing in it
        XCTAssert(disk.isEmpty)
        // expectation is the repository should load from the bundle in the absence of a stored file
        let loadedMetadata = repository.loadInstanceMetadata()
        
        // assert we were given the values from the bundle
        XCTAssertEqual(loadedMetadata.value, bundledFile.value)
    }
    
    func testLatestInstanceMetaDataIsPreferred() async throws {
        // create a repository with a stubbed '.now' date of Fri Feb 13 2009 23:30:00 GMT+0000
        let repository = withDependencies {
            $0.date.now = .init(timeIntervalSince1970: 1_234_567_890)
            $0.errorHandler = MockErrorHandler { self.errors.append($0) }
        } operation: {
            PersistenceRepository(
                keychainAccess: { self.keychain[$0] },
                read: { url in
                    guard let data = self.disk[url] else {
                        throw PersistenceTestError.noDataForURL
                    }
                    
                    return data
                },
                write: { self.disk[$1] = $0 },
                bundle: Bundle(for: type(of: self))
            )
        }
        
        // assert the disk is empty
        XCTAssert(disk.isEmpty)
        
        let metadata: [InstanceMetadata] = [
            .mock(url: .mock.appending(path: "/outdated_example1")),
            .mock(url: .mock.appending(path: "/outdated_example2"))
        ]
        
        // write the examples to disk, as the date is stubbed above the file will be stamped as Fri Feb 13 2009 23:30:00 GMT+0000
        try await repository.saveInstanceMetadata(metadata)
        
        // now ask the repository for the metadata, expectation is that although we have something on disk...
        // the bundled file is more recent, so we'll ignore the locally saved file and return the more recent bundled copy
        let loadedMetadata = repository.loadInstanceMetadata()
        XCTAssertEqual(loadedMetadata.value, try bundledMetadata.value)
    }
    
    // MARK: Test Helpers
    
    private func load<T: Decodable>(_ model: T.Type) throws -> T {
        let key = disk.keys.first
        let dataFromDisk = disk[key!]
        return try JSONDecoder().decode(T.self, from: dataFromDisk!)
    }
    
    var bundledMetadata: TimestampedValue<[InstanceMetadata]> {
        get throws {
            let path = Bundle(for: type(of: self)).path(forResource: "instance_metadata", ofType: "json")!
            let stringValue = try String(contentsOfFile: path)
            let data = stringValue.data(using: .utf8)!
            return try JSONDecoder().decode(TimestampedValue<[InstanceMetadata]>.self, from: data)
        }
    }
}

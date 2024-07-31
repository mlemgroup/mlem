//
//  PersistenceRepository.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Dependencies
import Foundation
import MlemMiddleware

private enum Path {
    private static var root = {
        guard let path = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            fatalError("unable to access application support path")
        }

        return path
    }()

    static var userAccounts = root.appendingPathComponent("Saved Accounts", conformingTo: .json)
    static var guestAccounts = root.appendingPathComponent("Guest Accounts", conformingTo: .json)
    static var filteredKeywords = root.appendingPathComponent("Blocked Keywords", conformingTo: .json)
    static var favoriteCommunities = root.appendingPathComponent("Favorite Communities", conformingTo: .json)
    static var recentSearches = root.appendingPathComponent("Recent Searches", conformingTo: .json)
    static var easterFlags = root.appendingPathComponent("Easter eggs flags", conformingTo: .json)
    static var layoutWidgets = root.appendingPathComponent("Layout Widgets", conformingTo: .json)
    static var instanceMetadata = root.appendingPathComponent("Instance Metadata", conformingTo: .json)
}

private enum DiskAccess {
    static func load(from path: URL) throws -> Data {
        try Data(contentsOf: path, options: .mappedIfSafe)
    }
    
    static func save(_ data: Data, to path: URL) async throws {
        try await Task(priority: .background) {
            try data.write(to: path, options: .atomic)
        }
        .value
    }
}

class PersistenceRepository {
    @Dependency(\.date) private var date
    
    private var keychainAccess: (String) -> String?
    private var read: (URL) throws -> Data
    private var write: (Data, URL) async throws -> Void
    private let bundle: Bundle
    
    init(
        keychainAccess: @escaping (String) -> String?,
        read: @escaping (URL) throws -> Data = { try DiskAccess.load(from: $0) },
        write: @escaping (Data, URL) async throws -> Void = { try await DiskAccess.save($0, to: $1) },
        bundle: Bundle = Bundle.main
    ) {
        self.keychainAccess = keychainAccess
        self.read = read
        self.write = write
        self.bundle = bundle
    }
    
    // MARK: - Public methods
    
    func loadUserAccounts() -> [UserAccount] {
        load([UserAccount].self, from: Path.userAccounts) ?? []
    }
    
    func saveUserAccounts(_ value: [UserAccount]) async throws {
        try await save(value, to: Path.userAccounts)
    }
    
    func loadGuestAccounts() -> [GuestAccount] {
        load([GuestAccount].self, from: Path.guestAccounts) ?? []
    }
    
    func saveGuestAccounts(_ value: [GuestAccount]) async throws {
        try await save(value, to: Path.guestAccounts)
    }

//
//    func loadRecentSearches(for accountId: String) -> [ContentModelIdentifier] {
//        let searches = load([String: [ContentModelIdentifier]].self, from: Path.recentSearches) ?? [:]
//        return searches[accountId] ?? []
//    }
//
//    func saveRecentSearches(for accountId: String, with searches: [ContentModelIdentifier]) async throws {
//        var extant = load([String: [ContentModelIdentifier]].self, from: Path.recentSearches) ?? [:]
//        extant[accountId] = searches
//        try await save(extant, to: Path.recentSearches)
//    }
//
//    func loadFavoriteCommunities() -> [FavoriteCommunity] {
//        load([FavoriteCommunity].self, from: Path.favoriteCommunities) ?? []
//    }
//
//    func saveFavoriteCommunities(_ value: [FavoriteCommunity]) async throws {
//        try await save(value, to: Path.favoriteCommunities)
//    }
//
//    func loadEasterFlags() -> Set<EasterFlag> {
//        load(Set<EasterFlag>.self, from: Path.easterFlags) ?? .init()
//    }
//
//    func saveEasterFlags(_ value: Set<EasterFlag>) async throws {
//        try await save(value, to: Path.easterFlags)
//    }
    
    func loadFilteredKeywords() -> [String] {
        load([String].self, from: Path.filteredKeywords) ?? []
    }
    
    func saveFilteredKeywords(_ value: [String]) async throws {
        try await save(value, to: Path.filteredKeywords)
    }
    
    func getFilteredKeywordsPath() -> URL {
        Path.filteredKeywords
    }
    
//    func loadLayoutWidgets() -> LayoutWidgetGroups {
//        load(LayoutWidgetGroups.self, from: Path.layoutWidgets) ?? .init()
//    }
//
//    func saveLayoutWidgets(_ value: LayoutWidgetGroups) async throws {
//        try await save(value, to: Path.layoutWidgets)
//    }
//
//    func loadInstanceMetadata() -> TimestampedValue<[InstanceMetadata]> {
//        let localFile = load(TimestampedValue<[InstanceMetadata]>.self, from: Path.instanceMetadata)
//        let bundledFile = loadFromBundle(TimestampedValue<[InstanceMetadata]>.self, filename: "instance_metadata")
//
//        if let localFile, localFile.timestamp > bundledFile.timestamp {
//            return localFile
//        }
//
//        return bundledFile
//    }
//
//    func saveInstanceMetadata(_ value: [InstanceMetadata]) async throws {
//        let timestamped = TimestampedValue(value: value, timestamp: date.now, lifespan: .days(1))
//        try await save(timestamped, to: Path.instanceMetadata)
//    }
    
    // MARK: Private methods
    
    private func load<T: Decodable>(_ model: T.Type, from path: URL) -> T? {
        do {
            let data = try read(path)
            
            guard !data.isEmpty else {
                return nil
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func loadFromBundle<T: Decodable>(_ model: T.Type, filename: String, type: String = "json") -> T {
        do {
            let path = bundle.path(forResource: filename, ofType: type)!
            let stringValue = try String(contentsOfFile: path)
            let data = stringValue.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            fatalError("☠️ failed to load \(filename).\(type) from the application bundle.")
        }
    }
    
    private func save(_ value: some Encodable, to path: URL) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try await write(data, path)
        } catch {
            handleError(error)
        }
    }
}

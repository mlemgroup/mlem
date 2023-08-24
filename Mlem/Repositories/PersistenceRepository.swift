//
//  PersistenceRepository.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Dependencies
import Foundation

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

    static var savedAccounts = root.appendingPathComponent("Saved Accounts", conformingTo: .json)
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
    @Dependency(\.errorHandler) private var errorHandler
    
    private var keychainAccess: (String) -> String?
    private var read: (URL) throws -> Data
    private var write: (Data, URL) async throws -> Void
    
    init(
        keychainAccess: @escaping (String) -> String?,
        read: @escaping (URL) throws -> Data = { try DiskAccess.load(from: $0) },
        write: @escaping (Data, URL) async throws -> Void = { try await DiskAccess.save($0, to: $1) }
    ) {
        self.keychainAccess = keychainAccess
        self.read = read
        self.write = write
    }
    
    // MARK: - Public methods
    
    func loadAccounts() -> [SavedAccount] {
        let accounts = load([SavedAccount].self, from: Path.savedAccounts) ?? []
        return accounts.compactMap { account -> SavedAccount? in
            guard let token = keychainAccess("\(account.id)_accessToken") else {
                return nil
            }
            
            return SavedAccount(from: account, accessToken: token)
        }
    }
    
    func saveAccounts(_ value: [SavedAccount]) async throws {
        try await save(value, to: Path.savedAccounts)
    }
    
    func loadRecentSearches() -> [String] {
        load([String].self, from: Path.recentSearches) ?? []
    }
    
    func saveRecentSearches(_ value: [String]) async throws {
        try await save(value, to: Path.recentSearches)
    }
    
    func loadFavoriteCommunities() -> [FavoriteCommunity] {
        load([FavoriteCommunity].self, from: Path.favoriteCommunities) ?? []
    }
    
    func saveFavoriteCommunities(_ value: [FavoriteCommunity]) async throws {
        try await save(value, to: Path.favoriteCommunities)
    }
    
    func loadEasterFlags() -> Set<EasterFlag> {
        load(Set<EasterFlag>.self, from: Path.easterFlags) ?? .init()
    }
    
    func saveEasterFlags(_ value: Set<EasterFlag>) async throws {
        try await save(value, to: Path.easterFlags)
    }
    
    func loadFilteredKeywords() -> [String] {
        load([String].self, from: Path.filteredKeywords) ?? []
    }
    
    func saveFilteredKeywords(_ value: [String]) async throws {
        try await save(value, to: Path.filteredKeywords)
    }
    
    func loadLayoutWidgets() -> LayoutWidgetGroups {
        load(LayoutWidgetGroups.self, from: Path.layoutWidgets) ?? .init()
    }
    
    func saveLayoutWidgets(_ value: LayoutWidgetGroups) async throws {
        try await save(value, to: Path.layoutWidgets)
    }
    
    func loadInstanceMetadata() -> [InstanceMetadata] {
        load([InstanceMetadata].self, from: Path.instanceMetadata) ?? []
    }
    
    func saveInstanceMetadata(_ value: [InstanceMetadata]) async throws {
        try await save(value, to: Path.instanceMetadata)
    }
    
    // MARK: Private methods
    
    private func load<T: Decodable>(_ model: T.Type, from path: URL) -> T? {
        do {
            let data = try read(path)
            
            guard !data.isEmpty else {
                return nil
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            errorHandler.handle(error)
            
            return nil
        }
    }
    
    private func save(_ value: some Encodable, to path: URL) async throws {
        do {
            let data = try JSONEncoder().encode(value)
            try await write(data, path)
        } catch {
            errorHandler.handle(error)
        }
    }
}

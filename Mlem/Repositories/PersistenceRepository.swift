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

    static var savedAccounts = { root.appendingPathComponent("Saved Accounts", conformingTo: .json) }()
    static var filteredKeywords = { root.appendingPathComponent("Blocked Keywords", conformingTo: .json) }()
    static var favoriteCommunities = { root.appendingPathComponent("Favorite Communities", conformingTo: .json) }()
    static var recentSearches = { root.appendingPathComponent("Recent Searches", conformingTo: .json) }()
    static var easterFlags = { root.appendingPathComponent("Easter eggs flags", conformingTo: .json) }()
}

class PersistenceRepository {
    
    @Dependency(\.errorHandler) private var errorHandler
    
    // MARK: - Public methods
    
    func loadAccounts() -> [SavedAccount] {
        let accounts = load([SavedAccount].self, from: Path.savedAccounts) ?? []
        return accounts.compactMap { account -> SavedAccount? in
            guard let token = AppConstants.keychain["\(account.id)_accessToken"] else {
                return nil
            }

            return SavedAccount(
                id: account.id,
                instanceLink: account.instanceLink,
                accessToken: token,
                username: account.username
            )
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
    
    // MARK: Private methods
    
    private func load<T: Decodable>(_ model: T.Type, from path: URL) -> T? {
        do {
            let data = try Data(contentsOf: path, options: .mappedIfSafe)
            
            guard !data.isEmpty else {
                return nil
            }
            
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            errorHandler.handle(
                .init(underlyingError: error)
            )
            
            return nil
        }
    }
    
    private func save<T: Encodable>(_ value: T, to path: URL) async throws {
        return try await Task(priority: .background) {
            do {
                let data = try JSONEncoder().encode(value)
                try data.write(to: path, options: .atomic)
            } catch {
                errorHandler.handle(
                    .init(underlyingError: error)
                )
                
                throw error
            }
        }.value
    }
}

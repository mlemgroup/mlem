// 
//  PersistenceRepository.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//  
//

import Dependencies
import Foundation

class PersistenceRepository {
    
    @Dependency(\.errorHandler) private var errorHandler
    
    // MARK: - Public methods
    
    func loadAccounts() -> [SavedAccount] {
        let accounts = load([SavedAccount].self, from: AppConstants.savedAccountsFilePath) ?? []
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
    
    func saveAccounts(_ value: [SavedAccount]) {
        save(value, to: AppConstants.savedAccountsFilePath)
    }
    
    func loadRecentSearches() -> [String] {
        load([String].self, from: AppConstants.recentSearchesFilePath) ?? []
    }
    
    func saveRecentSearches(_ value: [String]) {
        save(value, to: AppConstants.recentSearchesFilePath)
    }
    
    func loadFavoriteCommunities() -> [FavoriteCommunity] {
        load([FavoriteCommunity].self, from: AppConstants.favoriteCommunitiesFilePath) ?? []
    }
    
    func saveFavoriteCommunities(_ value: [FavoriteCommunity]) {
        save(value, to: AppConstants.favoriteCommunitiesFilePath)
    }
    
    func loadEasterFlags() -> Set<EasterFlag> {
        load(Set<EasterFlag>.self, from: AppConstants.easterFlagsFilePath) ?? .init()
    }
    
    func saveEasterFlags(_ value: Set<EasterFlag>) {
        save(value, to: AppConstants.easterFlagsFilePath)
    }
    
    func loadFilteredKeywords() -> [String] {
        load([String].self, from: AppConstants.filteredKeywordsFilePath) ?? []
    }
    
    func saveFilteredKeywords(_ value: [String]) {
        save(value, to: AppConstants.filteredKeywordsFilePath)
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
    
    private func save<T: Encodable>(_ value: T, to path: URL) {
        Task(priority: .background) {
            do {
                let data = try JSONEncoder().encode(value)
                try data.write(to: path, options: .atomic)
            } catch {
                errorHandler.handle(
                    .init(underlyingError: error)
                )
            }
        }
    }
}

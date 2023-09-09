//
//  Favorites Tracker.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Combine
import Dependencies
import Foundation

class FavoriteCommunitiesTracker: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published var favoritesForCurrentAccount: [APICommunity] = .init()
    
    @Published private var favoriteCommunities: [FavoriteCommunity] = .init()
    private var account: SavedAccount?
    private var updateObserver: AnyCancellable?

    // MARK: - Initialisation
    
    init() {
        self.favoriteCommunities = persistenceRepository.loadFavoriteCommunities()
        self.updateObserver = $favoriteCommunities
            .sink { [weak self] in
                self?.favoritesDidChange($0)
            }
    }
    
    // MARK: - Public Methods
    
    /// A method to associate an account with the favorites tracker, once an account has been set calling it's methods will store/remove/return communities relating to the account
    /// - Parameter account: The `SavedAccount` to associate with the tracker
    func configure(for account: SavedAccount) {
        self.account = account
        favoritesForCurrentAccount = favoriteCommunities
            .filter { $0.forAccountID == account.id }
            .map(\.community)
    }
    
    /// A method to clear the account that is currently associated with the favorites tracker
    func clearStoredAccount() {
        account = nil
    }
    
    func favorite(_ community: APICommunity) {
        guard let account else {
            assertionFailure("Attempted to favorite community while no account is present")
            return
        }
        
        let newFavorite = FavoriteCommunity(forAccountID: account.id, community: community)
        favoriteCommunities.append(newFavorite)
    }
    
    func unfavorite(_ community: APICommunity) {
        guard let account else {
            assertionFailure("Attempted to unfavorite community while no account is present")
            return
        }
        
        favoriteCommunities.removeAll(where: { $0.community.id == community.id && $0.forAccountID == account.id })
    }
    
    func isFavorited(_ community: APICommunity) -> Bool {
        favoritesForCurrentAccount.contains(community)
    }
    
    func clearCurrentFavourites() {
        guard let account else {
            assertionFailure("Attempted to clear favorites while no account is present")
            return
        }
        
        let filteredFavorites = favoriteCommunities.filter { $0.forAccountID != account.id }
        favoriteCommunities = filteredFavorites
    }
    
    // MARK: - Private Methods
    
    private func favoritesDidChange(_ newValue: [FavoriteCommunity]) {
        if let account {
            favoritesForCurrentAccount = newValue
                .filter { $0.forAccountID == account.id }
                .map(\.community)
        }
        
        Task { [weak self] in
            try await self?.persistenceRepository.saveFavoriteCommunities(newValue)
        }
    }
}

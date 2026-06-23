//
//  SubscriptionList.swift
//
//
//  Created by Sjmarf on 05/05/2024.
//

import Observation

@Observable
public class SubscriptionList {
    /// All subscribed-to communities, including favorited communities.
    public private(set) var communities: Set<Community> = .init() {
        didSet {
            communityIds = .init(communities.map(\.id))
        }
    }

    public private(set) var communityIds: Set<Int> = .init()
    public private(set) var favorites: [Community] = .init()
    public private(set) var alphabeticSections: [String?: [Community]] = .init()
    public private(set) var instanceSections: [String?: [Community]] = .init()
    
    public internal(set) var hasLoaded: Bool = false
    
    var favoriteIDs: Set<Int> {
        get { getFavorites() }
        set { setFavorites(newValue) }
    }
    
    private var getFavorites: () -> Set<Int>
    private var setFavorites: (Set<Int>) -> Void
    
    private var api: ApiClient
    
    init(
        apiClient: ApiClient,
        getFavorites: @escaping () -> Set<Int>,
        setFavorites: @escaping (Set<Int>) -> Void
    ) {
        self.api = apiClient
        self.getFavorites = getFavorites
        self.setFavorites = setFavorites
    }
    
    public func refresh() async throws {
        _ = try await api.getSubscriptionList()
    }
    
    public func isFavorited(_ community: Community) -> Bool {
        favoriteIDs.contains(community.id)
    }
    
    private func alphabeticCategoryForCommunity(_ community: Community) -> String? {
        let first = String(community.name.first ?? "#").folding(options: .diacriticInsensitive, locale: .current)
        guard first.first?.isLetter ?? false else { return nil }
        return first.uppercased()
    }
    
    @MainActor
    func updateCommunities(with communities: Set<Community>) {
        self.communities = communities
        
        // Alphabetical
        
        var alphabeticSections: [String?: [Community]] = .init()
        
        let alphabeticSectionsGrouping: [String?: [Community]] = .init(
            grouping: communities,
            by: { alphabeticCategoryForCommunity($0) }
        )
        for section in alphabeticSectionsGrouping {
            alphabeticSections[section.key] = section.value.sorted(by: self.sortPredicate)
        }
        
        self.alphabeticSections = alphabeticSections
        
        // Instance
        
        var otherSection = [Community]()
        let instanceSectionsGrouping: [String?: [Community]] = .init(grouping: communities, by: \.host)
        var instanceSections: [String?: [Community]] = .init()
        
        for section in instanceSectionsGrouping {
            if section.value.count == 1, let community = section.value.first {
                otherSection.append(community)
            } else {
                instanceSections[section.key] = section.value.sorted(by: self.sortPredicate)
            }
        }
        if !otherSection.isEmpty {
            instanceSections[nil] = otherSection.sorted(by: self.sortPredicate)
        }
        self.instanceSections = instanceSections
        
        favorites = communities.filter { favoriteIDs.contains($0.id) }.sorted(by: self.sortPredicate)
    }
    
    func updateCommunitySubscription(community: Community) {
        guard hasLoaded, let subscription = community.subscription.value else { return }
        if subscription.subscribed {
            if !communities.contains(community) {
                addCommunity(community: community)
            }
            if isFavorited(community) != community.shouldBeFavorited {
                if community.shouldBeFavorited {
                    favoriteIDs.insert(community.id)
                    favorites.sortedInsert(community, by: self.sortPredicate)
                } else {
                    favoriteIDs.remove(community.id)
                    favorites.removeFirst { $0 === community }
                }
            }
        } else if communities.contains(community) {
            removeCommunity(community: community)
        }
    }
        
    private func addCommunity(community: Community) {
        communities.insert(community)
        
        let alphabeticCategory = alphabeticCategoryForCommunity(community)
        if alphabeticSections.keys.contains(alphabeticCategory) {
            alphabeticSections[alphabeticCategory]?.sortedInsert(community, by: self.sortPredicate)
        } else {
            alphabeticSections[alphabeticCategory] = [community]
        }
        
        let hostCategoryExists = instanceSections.keys.contains(community.host)
        let hostExists: Bool = (
            hostCategoryExists || instanceSections[nil, default: []].contains(where: { $0.host == community.host })
        )
        
        if hostExists {
            if hostCategoryExists {
                instanceSections[community.host]?.sortedInsert(community, by: self.sortPredicate)
            } else {
                if let otherCommunity = instanceSections[nil]?.removeFirst(where: { $0.host == community.host }) {
                    instanceSections[community.host] = [community, otherCommunity].sorted(by: self.sortPredicate)
                } else {
                    instanceSections[nil, default: []].append(community)
                }
            }
        }
    }
    
    private func removeCommunity(community: Community) {
        communities.remove(community)
        favoriteIDs.remove(community.id)
        favorites.removeFirst { $0 === community }
        let category = alphabeticCategoryForCommunity(community)
        alphabeticSections[category]?.removeFirst { $0 === community }
        if alphabeticSections[category]?.isEmpty ?? false {
            alphabeticSections.removeValue(forKey: category)
        }
        
        if var items = instanceSections[community.host] {
            switch items.count {
            case 1:
                instanceSections.removeValue(forKey: community.host)
                // Instance sections must contain at least two communities. If there is only one, it goes in
                // the // "other" section instead. If we're removing a community from an instance section of
                // size 2, we therefore need to move the remaining community to the "other" section.
            case 2:
                items.removeFirst { $0 === community }
                instanceSections[nil, default: []].sortedInsert(items[0], by: self.sortPredicate)
                instanceSections.removeValue(forKey: community.host)
            default:
                instanceSections[community.host]?.removeFirst { $0 === community }
            }
        } else {
            alphabeticSections[nil]?.removeFirst { $0 === community }
        }
    }

    private func sortPredicate(_ first: Community, _ second: Community) -> Bool {
        let result = first.name.localizedCompare(second.name)
        return switch result {
        case .orderedAscending: true
        case .orderedDescending: false
        case .orderedSame: first.host.localizedCompare(second.host) == .orderedAscending
        }
    }
}

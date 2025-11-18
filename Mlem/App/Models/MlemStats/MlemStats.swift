//
//  MlemStats.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

/// Class exposing instance search functionality. Instance data is fetched from the Mlem backend.
class MlemStats {
    enum MlemStatsApiClientError: Error { case failed }
    private(set) var instances: [InstanceSummary]?

    private(set) var loadingState: LoadingState = .idle
    private(set) var errorDetails: ErrorDetails?
    
    // This set is queried for use in link-handling.
    // Some of the largest instances are hard-coded just in-case the backend is down.
    private(set) var hosts: Set<String> = [
        "lemm.ee",
        "lemmy.world",
        "lemmy.ml",
        "sh.itjust.works",
        "beehaw.org",
        "lemmy.blahaj.zone",
        "sopuli.xyz",
        "programming.dev"
    ]
    
    static let main: MlemStats = .init()
    
    @MainActor
    func loadInstances(forceRefresh: Bool = false) async {
        guard forceRefresh || loadingState == .idle else { return }
        loadingState = .loading
        do {
            let decoder: JSONDecoder = .defaultDecoder
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let instances = try await BackendClient.main.getInstances()
            self.instances = instances
            hosts.formUnion(Set(instances.lazy.map(\.host)))
            loadingState = .done
            errorDetails = nil
        } catch {
            loadingState = .idle
            errorDetails = .init(error: error, refresh: {
                await self.loadInstances()
                return true
            })
        }
    }
    
    @MainActor
    func searchInstances(query: String, sort: InstanceSort = .score) async throws -> [InstanceSummary] {
        try await loadInstances()
        let instances: [InstanceSummary]
        if query.isEmpty {
            instances = self.instances ?? []
        } else {
            instances = self.instances?.filter {
                $0.host.localizedCaseInsensitiveContains(query)
                    || $0.name.localizedCaseInsensitiveContains(query)
            } ?? []
        }
        
        let filteredInstances = filterBlockedInstances(instances)
        
        switch sort {
        case .score:
            return filteredInstances
        case .users:
            return filteredInstances.sorted { $0.totalUsers > $1.totalUsers }
        case .alphabetical:
            return filteredInstances.sorted { $0.host < $1.host }
        case .version:
            return filteredInstances.sorted { $0.software.version > $1.software.version }
        }
    }
    
    private func filterBlockedInstances(_ instances: [InstanceSummary]) -> [InstanceSummary] {
        guard let session = AppState.main.firstSession as? UserSession, let blocks = session.blocks else {
            return instances
        }
        
        return instances.filter { instance in
            let actorId = ActorIdentifier.instance(host: instance.host)
            return !blocks.contains(instanceActorId: actorId)
        }
    }
}

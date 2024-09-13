//
//  MlemStats.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation
import MlemMiddleware

/// Class for accessing data from the [MlemStats repo](https://github.com/mlemgroup/mlem-stats).
class MlemStats {
    enum MlemStatsApiClientError: Error { case failed }
    private let urlSession: URLSession = .init(configuration: .default)
    private var loadingState: LoadingState = .idle
    
    private(set) var instances: [InstanceSummary]?
    
    // This set is queried for use in link-handling.
    // Some of the largest instances are hard-coded just in-case GitHub is down.
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
    func loadInstances() async throws {
        guard loadingState == .idle else { return }
        loadingState = .loading
        do {
            let decoder: JSONDecoder = .defaultDecoder
            if let url = URL(string: "https://raw.githubusercontent.com/mlemgroup/mlem-stats/master/output/instances_by_score.json") {
                if let data = try? await urlSession.data(from: url).0 {
                    let instances = try decoder.decode([InstanceSummary].self, from: data)
                    self.instances = instances
                    hosts.formUnion(Set(instances.lazy.map(\.host)))
                    loadingState = .done
                    return
                }
            }
            throw MlemStatsApiClientError.failed
        } catch {
            loadingState = .idle
            throw error
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
        switch sort {
        case .score:
            return instances
        case .users:
            return instances.sorted { $0.userCount > $1.userCount }
        case .alphabetical:
            return instances.sorted { $0.host < $1.host }
        case .version:
            return instances.sorted { $0.version > $1.version }
        }
    }
}

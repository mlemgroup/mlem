//
//  Instance Picker View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Foundation

extension InstancePickerView {
    func loadInstances() async -> [InstanceMetadata] {
        let savedInstances = persistenceRepository.loadInstanceMetadata()
        
        if savedInstances.isStale {
            // the saved values we have are stale, so update from remote if we can
            do {
                let instances = try await fetchInstances()
                save(instances)
                return instances
            } catch {
                // as we failed to retrieve/parse from remote, fallback to saved regardless of it's age
                errorHandler.handle(error)
                return savedInstances.value
            }
        } else {
            // the value we have saved is recent enough to use
            return savedInstances.value
        }
    }
    
    private func save(_ instances: [InstanceMetadata]) {
        Task {
            try await persistenceRepository.saveInstanceMetadata(instances)
        }
    }
    
    /// Retrieves instance metadata from awesome-lemmy-instances
    /// - Returns: A list of `InstanceMetadata` from the remote source
    private func fetchInstances() async throws -> [InstanceMetadata] {
        let url = URL(string: "https://raw.githubusercontent.com/maltfield/awesome-lemmy-instances/main/awesome-lemmy-instances.csv")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try InstanceMetadataParser.parse(from: data)
        } catch {
            errorHandler.handle(error)
            throw error
        }
    }
}

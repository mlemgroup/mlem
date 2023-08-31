//
//  Instance Picker View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Foundation

extension InstancePickerView {
    func loadInstances() async {
        print("loading instances...")
        
        let savedInstances = persistenceRepository.loadInstanceMetadata()
        
        if savedInstances.isEmpty {
            print("no saved instances, loading from remote")
            
            if let newInstances = await fetchInstances() {
                instances = newInstances
                do {
                    try await persistenceRepository.saveInstanceMetadata(newInstances)
                } catch {
                    errorHandler.handle(error)
                }
            }
        } else {
            print("found saved instances")
            instances = savedInstances
        }
    }
    
    /**
     Retrieves instance metadata from awesome-lemmy-instances
     */
    private func fetchInstances() async -> [InstanceMetadata]? {
        if let url = URL(string: "https://raw.githubusercontent.com/maltfield/awesome-lemmy-instances/main/awesome-lemmy-instances.csv") {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return try InstanceMetadataParser.parse(from: data)
            } catch {
                errorHandler.handle(error)
            }
        }
        
        return nil
    }
}

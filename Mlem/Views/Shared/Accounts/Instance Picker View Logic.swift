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
                if let dataString = String(data: data, encoding: .utf8) {
                    // split by newlines and remove header row
                    var splitData: [Substring] = dataString.split(separator: "\n")
                    
                    // ensure this is the data we think it is
                    guard splitData.removeFirst() == "Instance,NU,NC,Fed,Adult,↓V,Users,BI,BB,UT,Version" else {
                        print("Unexpected header line")
                        return nil
                    }
                    
                    // map lines to InstanceMetadata structs
                    let ret: [InstanceMetadata] = splitData
                        .compactMap { line in
                            let ret = parseInstanceMetadata(from: line)
                            if ret == nil { print("Failed to parse line: \(line)") }
                            return ret
                        }
                    
                    // if found some instances, return them
                    return ret.count > 0 ? ret : nil
                }
            } catch {
                errorHandler.handle(error)
            }
        }
        
        return nil
    }
    
    /**
     Parses a CSV line into instance metadata
     */
    private func parseInstanceMetadata(from line: Substring) -> InstanceMetadata? {
        let fields = line.split(separator: ",")
        guard fields.count == 11 else { return nil }
        
        // matches [instance name](instance url)
        guard let urlMatch = fields[0].firstMatch(of: /\[(?'name'.*)\]\((?'url'.*)\)/) else { return nil }

        let name = String(urlMatch.output.name)
        guard let url = URL(string: String(urlMatch.output.url)) else { return nil }
        let newUsers = fields[1] == "Yes"
        let newCommunities = fields[2] == "Yes"
        let federated = fields[3] == "Yes"
        let adult = fields[4] == "Yes"
        let downvotes = fields[5] == "Yes"
        guard let users = Int(fields[6]) else { return nil }
        guard let blocking = Int(fields[7]) else { return nil }
        guard let blockedBy = Int(fields[8]) else { return nil }
        let uptime = String(fields[9])
        let version = String(fields[10])
        
        return InstanceMetadata(
            name: name,
            url: url,
            newUsers: newUsers,
            newCommunities: newCommunities,
            federated: federated,
            adult: adult,
            downvotes: downvotes,
            users: users,
            blocking: blocking,
            blockedBy: blockedBy,
            uptime: uptime,
            version: version
        )
    }
}

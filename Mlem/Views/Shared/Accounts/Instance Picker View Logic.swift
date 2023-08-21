//
//  InstancePickerViewLogic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-16.
//

import Foundation

extension InstancePickerView {
    func loadInstances() {
        print("loading instances...")
        
        let savedInstances = persistenceRepository.loadInstanceMetadata()
        
        if savedInstances.isEmpty {
            print("no saved instances, loading from remote")
            fetchInstances { fetchedInstances in
                instances = fetchedInstances
                Task(priority: .background) {
                    try await persistenceRepository.saveInstanceMetadata(fetchedInstances)
                }
            }
        } else {
            print("found saved instances")
            instances = savedInstances
        }
    }
    
    /**
     Retrieves instance metadata from 
     */
    private func fetchInstances(callback: @escaping ([InstanceMetadata]) -> Void) {
        if let url = URL(string: AppConstants.instanceMetadataUrl) {
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = data else {
                    fetchFailed = true
                    return
                }
                
                if let dataString = String(data: data, encoding: .utf8) {
                    // split by newlines and remove header row
                    var splitData: [Substring] = dataString.split(separator: "\n")
                    
                    // ensure this is the data we think it is
                    guard splitData.removeFirst() == "Instance,NU,NC,Fed,Adult,↓V,Users,BI,BB,UT,Version" else {
                        print("Unexpected header line")
                        fetchFailed = true
                        return
                    }
                    
                    // map lines to InstanceMetadata structs
                    let ret: [InstanceMetadata] = splitData
                        .compactMap { line in
                            let ret = parseInstanceMetadata(from: line)
                            if ret == nil { print("Failed to parse line: \(line)") }
                            return ret
                        }
                    
                    // if found some instances, call callback
                    if ret.count > 0 {
                        callback(ret)
                    } else {
                        print("Found no instances")
                        fetchFailed = true
                    }
                } else {
                    fetchFailed = true
                }
            }.resume()
        }
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
        
        return InstanceMetadata(name: name,
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
                                version: version)
    }
}

//
//  InstanceView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2024.
//

import SwiftUI

extension InstanceView {
    var tabs: [Tab] {
        var output: [Tab] = [.about, .administration, .details]
        if instance.canFetchUptime {
            output.append(.uptime)
        }
        output.append(.safety)
        return output
    }
    
    func attemptToLoadUptimeData() {
        print("Fetching uptime data...")
        if let url = instance.uptimeDataUrl {
            Task {
                do {
                    let data = try await URLSession.shared.data(from: url).0
                    let uptimeData = try JSONDecoder.defaultDecoder.decode(UptimeData.self, from: data)
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.uptimeData = .success(uptimeData)
                        }
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    func attemptToLoadFediseerData() {
        if fediseerData == nil, let host = instance.host {
            Task {
                do {
                    guard let instanceURL = URL(string: "https://fediseer.com/api/v1/whitelist/\(host)") else { return }
                    async let instanceData = try await URLSession.shared.data(from: instanceURL).0
                    
                    async let endorsementsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/endorsements/\(host)")!
                    ).0
                    
                    async let hesitationsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/hesitations/\(host)")!
                    ).0
                    
                    async let censuresData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/censures/\(host)")!
                    ).0
                    
                    let fediseerData = try await FediseerData(
                        instance: JSONDecoder.defaultDecoder.decode(
                            FediseerInstance.self,
                            from: instanceData
                        ),
                        endorsements: JSONDecoder.defaultDecoder.decode(
                            FediseerEndorsements.self,
                            from: endorsementsData
                        ).instances,
                        hesitations: JSONDecoder.defaultDecoder.decode(
                            FediseerHesitations.self,
                            from: hesitationsData
                        ).instances,
                        censures: JSONDecoder.defaultDecoder.decode(
                            FediseerCensures.self,
                            from: censuresData
                        ).instances
                    )
                    
                    Task { @MainActor in
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.fediseerData = fediseerData
                        }
                    }
                } catch {
                    handleError(error)
                }
            }
        }
    }
}

//
//  InstanceView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

extension InstanceView {
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
                    errorHandler.handle(error)
                }
            }
        }
    }
    
    func attemptToLoadFediseerData() {
        if fediseerData == nil {
            Task {
                do {
                    guard let instanceURL = URL(string: "https://fediseer.com/api/v1/whitelist/\(instance.name)") else { return }
                    async let instanceData = try await URLSession.shared.data(from: instanceURL).0
                    
                    async let endorsementsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/endorsements/\(instance.name)")!
                    ).0
                    
                    async let hesitationsData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/hesitations/\(instance.name)")!
                    ).0
                    
                    async let censuresData = try await URLSession.shared.data(
                        from: URL(string: "https://fediseer.com/api/v1/censures/\(instance.name)")!
                    ).0
                    
                    let fediseerData = FediseerData(
                        instance: try JSONDecoder.defaultDecoder.decode(
                            FediseerInstance.self,
                            from: await instanceData
                        ),
                        endorsements: try JSONDecoder.defaultDecoder.decode(
                            FediseerEndorsements.self,
                            from: await endorsementsData
                        ).instances,
                        hesitations: try JSONDecoder.defaultDecoder.decode(
                            FediseerHesitations.self,
                            from: await hesitationsData
                        ).instances,
                        censures: try JSONDecoder.defaultDecoder.decode(
                            FediseerCensures.self,
                            from: await censuresData
                        ).instances
                    )
                    
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.2)) {
                            self.fediseerData = fediseerData
                        }
                    }
                } catch {
                    errorHandler.handle(error)
                }
            }
        }
    }
}

//
//  InstanceView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

extension InstanceView {
    
    // swiftlint:disable:next function_body_length
    func attemptToLoadInstanceData() {
        if instance.administrators == nil {
            Task {
                do {
                    if let url = URL(string: "https://\(instance.name)") {
                        let info = try await apiClient.loadSiteInformation(instanceURL: url)
                        DispatchQueue.main.async {
                            withAnimation(.easeOut(duration: 0.2)) {
                                instance.update(with: info)
                            }
                        }
                    } else {
                        errorDetails = ErrorDetails(title: "\"\(instance.name)\" is an invalid URL.")
                    }
                } catch let APIClientError.decoding(data, error) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        if let content = String(data: data, encoding: .utf8) {
                            if content.contains("<div class=\"kbin-container\">") {
                                errorDetails = ErrorDetails(
                                    title: "KBin Instance",
                                    body: "We can't display KBin instance details.",
                                    icon: Icons.federation
                                )
                            } else if content.contains("<body class=\"app-body theme-default no-reduce-motion layout-single-column\">") {
                                errorDetails = ErrorDetails(
                                    title: "Mastodon Instance",
                                    body: "We can't display Mastodon instance details.",
                                    icon: Icons.federation
                                )
                            } else {
                                errorDetails = ErrorDetails(error: APIClientError.decoding(data, error))
                            }
                        } else {
                            errorDetails = ErrorDetails(error: APIClientError.decoding(data, error))
                        }
                    }
                } catch let APIClientError.networking(error) {
                    if let urlError = error as? URLError {
                        if urlError.code.rawValue == -1202 {
                            errorDetails = ErrorDetails(
                                title: "Cannot reach instance",
                                body: "It's possible that access to this instance is disallowed by your network.",
                                error: error
                            )
                            return
                        }
                    }
                    errorDetails = ErrorDetails(error: APIClientError.networking(error))
                } catch {
                    withAnimation(.easeOut(duration: 0.2)) {
                        errorDetails = ErrorDetails(error: error)
                    }
                }
            }
        }
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

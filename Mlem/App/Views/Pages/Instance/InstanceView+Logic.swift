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
}

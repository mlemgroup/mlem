//
//  UptimeData.swift
//  Mlem
//
//  Created by Sjmarf on 28/01/2024.
//

import Foundation
import SwiftUI

struct UptimeData: Codable {
    let results: [UptimeResponseTime]
    let events: [UptimeEvent]
    
    var downtimes: [DowntimePeriod] {
        var ret: [DowntimePeriod] = []
        var previous: UptimeEvent?
        for event in events {
            if event.type == .healthy {
                if let previous {
                    ret.append(.init(startTime: previous.timestamp, endTime: event.timestamp))
                }
            }
            previous = event
        }
        return ret.reversed()
    }
}

struct UptimeResponseTime: Codable, Identifiable {
    let success: Bool
    let duration: Int
    let timestamp: Date
    
    var durationMs: Int {
        duration / 1_000_000
    }
    
    var id: Int { Int(timestamp.timeIntervalSince1970) }
}

struct UptimeEvent: Codable, Identifiable {
    enum EventType: String, Codable {
        case healthy = "HEALTHY"
        case unhealthy = "UNHEALTHY"
    }
    
    let type: EventType
    let timestamp: Date
    
    var id: Int { Int(timestamp.timeIntervalSince1970) }
}

struct DowntimePeriod: Codable, Identifiable {
    let startTime: Date
    let endTime: Date
    
    var id: Int { Int(startTime.timeIntervalSince1970) }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var severityColor: Color {
        if duration < 60 * 5 {
            .secondary
        } else if duration < 60 * 30 {
            .orange
        } else {
            .red
        }
    }
    
    func differenceTitle(unitsStyle: DateComponentsFormatter.UnitsStyle = .short) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.maximumUnitCount = 2
        return formatter.string(from: duration) ?? "Unknown"
    }
    
    var relativeTimeCaption: String {
        endTime.getRelativeTime()
    }
    
    private var timeOnlyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
    
    private var dateAndTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    var differenceCaption: String {
        if duration < 60 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: startTime)
        }
        
        let onSameDay = Calendar.current.isDate(startTime, equalTo: endTime, toGranularity: .day)
        
        if onSameDay {
            return "\(dateAndTimeFormatter.string(from: startTime)) to \(timeOnlyFormatter.string(from: endTime))"
        }
        
        return "\(dateAndTimeFormatter.string(from: startTime)) to \(dateAndTimeFormatter.string(from: endTime))"
    }
}

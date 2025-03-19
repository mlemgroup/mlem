//
//  SortTimeRange+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-01.
//

import Foundation
import MlemMiddleware

extension SortTimeRange {
    enum FormatStyle {
        case topOnly
        case timescaleAbbreviated
        case timescaleFull
        case topAndTimescale
    }
    
    func label(name: LocalizedStringResource, prefix: LocalizedStringResource, format: FormatStyle) -> String {
        switch format {
        case .topOnly:
            String(localized: name)
        case .topAndTimescale:
            "\(String(localized: prefix)) \(label(abbreviateUnits: false))"
        case .timescaleAbbreviated:
            label(abbreviateUnits: true)
        case .timescaleFull:
            label(abbreviateUnits: false)
        }
    }
    
    private func label(abbreviateUnits: Bool) -> String {
        switch self {
        case let .limited(timeInterval):
            var seconds = Int(timeInterval)
            
            let dateComponents: DateComponents
            
            // Check if time range is exact number of weeks
            if seconds % (3600 * 24 * 7) == 0 {
                dateComponents = .init(weekOfMonth: seconds / (3600 * 24 * 7))
            } else {
                // Convert a year to exactly 365 days
                let years = seconds / (3600 * 24 * 365)
                seconds %= (3600 * 24 * 365)
                // Convert a month to exactly 30 days
                let months = seconds / (3600 * 24 * 30)
                seconds %= (3600 * 24 * 30)
                dateComponents = .init(year: years, month: months, second: seconds)
            }
            
            if abbreviateUnits {
                return formatter(unitsStyle: .abbreviated).string(for: dateComponents) ?? ""
            } else {
                return formatter(unitsStyle: .full)
                    .string(for: dateComponents)?
                    .capitalized ?? ""
            }
        case .allTime:
            return abbreviateUnits ? .init(localized: "All") : .init(localized: "All Time")
        }
    }
    
    private func formatter(unitsStyle: DateComponentsFormatter.UnitsStyle) -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]
        return formatter
    }
}

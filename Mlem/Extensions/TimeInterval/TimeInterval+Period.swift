//
//  TimeInterval+Period.swift
//  Mlem
//
//  Created by mormaer on 28/08/2023.
//
//

import Foundation

extension TimeInterval {
    static func minutes(_ numberOfMinutes: Double) -> TimeInterval { 60 * numberOfMinutes }
    static func hours(_ numberOfHours: Double) -> TimeInterval { 3600 * numberOfHours }
    static func days(_ numberOfDays: Double) -> TimeInterval { 86400 * numberOfDays }
}

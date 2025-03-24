//
//  ActiveUserCount.swift
//
//
//  Created by Sjmarf on 29/05/2024.
//

import Foundation

public struct ActiveUserCount: Equatable {
    public let sixMonths: Int
    public let month: Int
    public let week: Int
    public let day: Int
    
    public init(sixMonths: Int, month: Int, week: Int, day: Int) {
        self.sixMonths = sixMonths
        self.month = month
        self.week = week
        self.day = day
    }
    
    public static let zero: ActiveUserCount = .init(sixMonths: 0, month: 0, week: 0, day: 0)
}

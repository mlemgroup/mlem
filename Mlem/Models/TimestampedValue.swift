//
//  TimestampedValue.swift
//  Mlem
//
//  Created by mormaer on 28/08/2023.
//
//

import Dependencies
import Foundation

/// A simple wrapper that can be used to store a value with a timestamp and expiration length
struct TimestampedValue<T> {
    
    @Dependency(\.date) var currentDate
    
    enum CodingKeys: String, CodingKey {
        case value
        case timestamp
        case lifespan
    }
    
    let value: T
    let timestamp: Date
    let lifespan: TimeInterval
    
    /// A method to determine if the `.value` contained in this wrapper should be considered out-of-date
    var isStale: Bool {
        abs(timestamp.timeIntervalSince(currentDate.now)) > lifespan
    }
    
    /// An initialiser which wraps the provided value
    /// - Parameters:
    ///   - value: The value to store
    ///   - timestamp: A `Date` representing when this file was created, defaults to `.now`
    ///   - lifespan: A `TimeInterval` describing how long this value should be considered valid (eg `.minutes(5)`)
    init(value: T, timestamp: Date = .now, lifespan: TimeInterval) {
        self.value = value
        self.timestamp = timestamp
        self.lifespan = lifespan
    }
}

// provide `Codable` conformance if the value we're storing is itself `Codable`

extension TimestampedValue: Codable where T: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.value = try container.decode(T.self, forKey: .value)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.lifespan = try container.decode(TimeInterval.self, forKey: .lifespan)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(value, forKey: .value)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lifespan, forKey: .lifespan)
    }
}

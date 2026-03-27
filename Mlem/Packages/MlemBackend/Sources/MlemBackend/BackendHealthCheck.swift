//
//  BackendHealthCheck.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-14.
//

import Foundation

public struct BackendHealthCheck: Decodable {
    var dbConnection: Bool
    var lastInstanceFetch: Date
    
    public var unhealthyReasons: [String] {
        guard let minimumAllowableFetch = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            assertionFailure("Could not compute minimum allowable fetch")
            return ["Could not compute minimum allowable fetch"]
        }
        
        var ret: [String] = .init()
        
        if !dbConnection {
            ret.append("No database connection")
        }
        
        if lastInstanceFetch <= minimumAllowableFetch {
            ret.append("Last fetch was \(lastInstanceFetch.formatted(date: .abbreviated, time: .standard))")
        }
        
        return ret
    }
}

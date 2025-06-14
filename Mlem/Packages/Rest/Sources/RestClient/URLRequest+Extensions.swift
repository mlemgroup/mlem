//
//  URLRequest+Extensions.swift
//
//
//  Created by Eric Andrews on 2024-07-03.
//
// https://stackoverflow.com/questions/34705449/how-to-print-http-request-to-console

import Foundation

extension URLRequest {
    /// Prints this URLRequest in human-readable form
    func debug() {
        print("\(httpMethod!) \(url!)")
        print("Headers:")
        print(allHTTPHeaderFields ?? [:])
        print("Body:")
        print(String(data: httpBody ?? Data(), encoding: .utf8)!)
    }
}

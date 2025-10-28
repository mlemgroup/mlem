//
//  URLRequest+Extensions.swift
//
//
//  Created by Eric Andrews on 2024-07-03.
//
// https://stackoverflow.com/questions/34705449/how-to-print-http-request-to-console

import Foundation
import MlemLogger
import os

extension URLRequest {
    /// Prints this URLRequest in human-readable form
    func debug() {
        let statement = """
        \(httpMethod!) \(url!)
        "Headers:"
        \(allHTTPHeaderFields ?? [:])
        "Body:"
        \(String(data: httpBody ?? Data(), encoding: .utf8)!)
        """
        Logger.universal.debug("\(statement)")
    }
}

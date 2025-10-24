//
//  URLRequest+Extensions.swift
//
//
//  Created by Eric Andrews on 2024-07-03.
//
// https://stackoverflow.com/questions/34705449/how-to-print-http-request-to-console

import Foundation
import os
import MlemLogger

extension URLRequest {
    /// Prints this URLRequest in human-readable form
    func trace() {
        let statement: String = """
        \(httpMethod!) \(url!)
        "Headers:"
        \(allHTTPHeaderFields ?? [:])
        "Body:"
        \(String(data: httpBody ?? Data(), encoding: .utf8)!)
        """
        Logger.universal.trace("\(statement)")
    }
}

//
//  URLSessionWebSocketTask - Send Ping.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

extension URLSessionWebSocketTask {
    func sendPing() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.sendPing { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

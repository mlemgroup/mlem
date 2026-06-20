//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-08-09.
//

import Foundation
import os

enum ConnectionMultiplexerError: Error {
    case allConnectionsFailed
}

class ConnectionMultiplexer<Candidate> {
    private let log: Logger = .mlemLogger()
    
    private var ongoingTask: Task<Any, Error>?
    
    var getCandidates: () -> [Candidate]
    var selectedCandidate: Candidate?
    
    init(getCandidates: @escaping () -> [Candidate]) {
        self.getCandidates = getCandidates
    }
    
    @MainActor
    func perform<T>(
        _ callback: @escaping (Candidate) async throws -> T
    ) async throws -> T {
        // Iterate through all possible candidates, and call the callback on each in turn.
        // As soon as one of the calls succeeds, return the result and cancel the other ongoing calls.
        // Cache the `Candidate` that succeeded in the `self.selectedCandidate` property, and use that
        // for all subsequent calls of `perform`.
        
        // If `perform` is called and `self.selectedCandidate` is `nil` but there is another
        // `perform` call ongoing, it will wait for the other call to succeed first.

        _ = await self.ongoingTask?.result
        if let selectedCandidate {
            return try await callback(selectedCandidate)
        }

        let ongoingTask: Task<T, Error> = Task {
            try await withThrowingTaskGroup(of: (Int, Result<T, Error>).self) { group in

                let candidates = self.getCandidates()

                for (index, candidate) in candidates.enumerated() {
                    group.addTask {
                        do {
                            let response = try await callback(candidate)
                            return (index, .success(response))
                        } catch {
                            return (index, .failure(error))
                        }
                    }
                }
                
                var results: [(Int, Result<T, Error>)] = []
                while !group.isEmpty {
                    guard let result = try? await group.next() else {
                        assertionFailure()
                        continue
                    }
                    results.append(result)
                }

                results.sort(by: { $0.0 < $1.0 })
                
                // Find first successful result in candidate order
                for (candidate, result) in zip(candidates, results.map(\.1)) {
                    do {
                        let value = try result.get()
                        log.info("Selected \(String(describing: candidate))")
                        self.selectedCandidate = candidate
                        self.ongoingTask = nil
                        return value
                    } catch ApiClientError.serverError(404), ApiClientError.response(_, 404), ApiClientError.featureUnsupported {
                        // no-op
                    } catch {
                        throw error
                    }
                }
                
                throw ConnectionMultiplexerError.allConnectionsFailed
            }
        }
        
        self.ongoingTask = Task {
            _ = try? await ongoingTask.result.get()
        }
        
        return try await ongoingTask.result.get()
    }
    
    func getConnection(callback: () async throws -> Void) async throws -> Candidate {
        _ = await ongoingTask?.result
        if let selectedCandidate {
            return selectedCandidate
        }
        try await callback()
        if let selectedCandidate {
            return selectedCandidate
        }
        assertionFailure()
        throw ApiClientError.unsuccessful
    }
}

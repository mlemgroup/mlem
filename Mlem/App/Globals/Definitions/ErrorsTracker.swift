//
//  ErrorsTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-29.
//

import Observation

@Observable
class ErrorsTracker {
    private(set) var errors: [ErrorDetails] = .init()
    
    @MainActor
    func addError(_ error: Error) {
        errors.append(.init(error: error))
    }
    
    static var main: ErrorsTracker = .init()
}

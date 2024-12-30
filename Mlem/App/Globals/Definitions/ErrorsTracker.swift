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
        errors.prepend(.init(error: error))
    }
    
    static var main: ErrorsTracker = .init()
    
    func createErrorLog() -> String {
        var ret: String = ""
        
        errors.forEach { details in
            let description = details.error?.localizedDescription ?? "No Description"
            ret += "\(details.when.formatted(.iso8601))\t\(details.title ?? "Error")\t\(description)\n"
        }
        
        return ret
    }
}

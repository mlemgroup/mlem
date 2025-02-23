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
    func addError(_ error: Error, location: String) {
        errors.prepend(.init(error: error, location: location))
    }
    
    static var main: ErrorsTracker = .init()
    
    func createErrorLog() -> String {
        var ret = ""
        
        for details in errors {
            ret += "\(details.when.formatted(.iso8601))\t\(details.title ?? "Error")\t\(details.errorText())\n"
        }
        
        return ret
    }
}

// 
//  ErrorHandler.swift
//  Mlem
//
//  Created by mormaer on 15/07/2023.
//  
//

import Dependencies
import Foundation

class ErrorHandler: ObservableObject {
    
    @Dependency(\.notifier) private var notifier
    
    @Published private(set) var sessionExpired = false
    
    private(set) var contextualError: ContextualError?
    
    func handle(_ error: ContextualError?) {
        guard let error else {
            return
        }
        
        #if DEBUG
        log(error)
        #endif

        Task { @MainActor in
            if let clientError = error.underlyingError.base as? APIClientError {
                switch clientError {
                case .invalidSession:
                    sessionExpired = true
                    return
                case let .response(apiError, _):
                    await notifier.add(.failure(apiError.error))
                    return
                default:
                    break
                }
            }
            
            await notifier.add(error)
        }
    }
    
    private func log(_ error: ContextualError) {
        print("☠️ ERROR ☠️")
        print("🕵️ -> \(error.underlyingError.description)")
        print("📝 -> \(error.underlyingError.localizedDescription)")
    }
}

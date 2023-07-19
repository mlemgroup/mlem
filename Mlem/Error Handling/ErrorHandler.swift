// 
//  ErrorHandler.swift
//  Mlem
//
//  Created by mormaer on 15/07/2023.
//  
//

import Foundation

class ErrorHandler: ObservableObject {
    
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
                    ErrorDisplayer.displayAlert(title: "Error", message: apiError.error)
                    return
                default:
                    break
                }
            }
            
            switch error.style {
            case .alert:
                ErrorDisplayer.displayAlert(title: error.title, message: error.message)
            case .toast:
                if let message = error.title ?? error.message {
                    ErrorDisplayer.displayToast(title: message)
                }
            }
            
        }
    }
    
    private func log(_ error: ContextualError) {
        print("☠️ ERROR ☠️")
        print("🕵️ -> \(error.underlyingError.description)")
        print("📝 -> \(error.underlyingError.localizedDescription)")
    }
}

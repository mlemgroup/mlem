// 
//  ErrorHandler.swift
//  Mlem
//
//  Created by mormaer on 15/07/2023.
//  
//

import Foundation

class ErrorHandler: ObservableObject {
    
    @Published var alert: ErrorAlert?
    @Published var sessionExpired = false
    
    private(set) var contextualError: ContextualError?
    
    func handle(_ error: ContextualError?) {
        guard let error else {
            return
        }
        
        #if DEBUG
        log(error)
        #endif

        Task {
            await MainActor.run {
                if let clientError = error.underlyingError.base as? APIClientError {
                    switch clientError {
                    case .invalidSession:
                        sessionExpired = true
                        return
                    case let .response(apiError, _):
                        alert = .init(title: "Error", message: apiError.error)
                        return
                    default:
                        break
                    }
                }

                let title = error.title ?? ""
                let message = error.message ?? ""

                guard !title.isEmpty || !message.isEmpty else {
                    // no title or message was supplied so don't notify the user of this...
                    return
                }

                alert = .init(title: title, message: message)
            }
        }
    }
    
    private func log(_ error: ContextualError) {
        print("☠️ ERROR ☠️")
        print("🕵️ -> \(error.underlyingError.description)")
        print("📝 -> \(error.underlyingError.localizedDescription)")
    }
}

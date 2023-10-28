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
    
    func handle(_ error: Error?, file: StaticString = #fileID, function: StaticString = #function, line: Int = #line) {
        guard let error else {
            return
        }
        
        handle(.init(underlyingError: error), file: file, function: function, line: line)
    }
    
    func handle(
        _ error: ContextualError?,
        file: StaticString = #fileID,
        function: StaticString = #function,
        line: Int = #line,
        showNoInternet: Bool = true
    ) {
        guard let error else {
            return
        }
        
        #if DEBUG
            log(error, file, function, line)
        #endif

        Task { @MainActor in
            
            if let clientError = error.underlyingError.base as? APIClientError {
                
                if case .invalidSession = clientError {
                    sessionExpired = true
                    return
                }
                
                if error.title != nil && !InternetConnectionManager.isConnectedToNetwork() {
                    if showNoInternet {
                        await notifier.add(.noInternet)
                    }
                    return
                }
                
                if case .response(let apiError, _) = clientError {
                    await notifier.add(.failure(apiError.error))
                    return
                }
            }
            
            // if it's not an API error or a session expiration just pass to our notifier
            // the notifier logic wil handle displaying the error if appropriate based
            // on the values supplied when the error was created
            await notifier.add(error)
        }
    }
    
    private func log(_ error: ContextualError, _ file: StaticString, _ function: StaticString, _ line: Int) {
        print("☠️ ERROR ☠️")
        print("🕵️ -> \(error.underlyingError.description)")
        print("📝 -> \(error.underlyingError.localizedDescription)")
        print("📂 -> \(file) | \(function) | line: \(line)")
    }
}

//
//  HandleError.swift
//  Mlem
//
//  Created by Sjmarf on 18/05/2024.
//

import MlemMiddleware
import os
import SwiftUI

func handleError(
    _ error: Error,
    silent: Bool = false,
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) {
    if !_handleError(error, file: file, function: function, line: line), !silent {
        ToastModel.main.add(.error(.init(error: error)))
    }
}

func handleErrorWithDetails(
    _ error: Error,
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) -> ErrorDetails? {
    if !_handleError(error, file: file, function: function, line: line) {
        return .init(error: error)
    }
    return nil
}

/// - Returns: true if no further handling is required, false otherwise
private func _handleError(
    _ error: Error,
    file: String = #fileID,
    function: String = #function,
    line: Int = #line
) -> Bool {
    #if DEBUG
        let descriptiveString: String
        if let error = error as? ApiClientError {
            descriptiveString = "     \(String(describing: error))\n"
        } else {
            descriptiveString = ""
        }
        let statement = """
        ☠️ ERROR ☠️
        📝 -> \(error.localizedDescription)
        \(descriptiveString)📂 -> \(file) | \(function) | line: \(line)
        """
        Logger.universal.error("\(statement)")
    #endif
    
    let location = "\(file), \(function):\(line)"
    
    Task {
        await ErrorsTracker.main.addError(error, location: location)
    }
    
    switch error {
    // TODO: Modify MlemMiddleware to attach the ApiClient throwing the error to ApiClientError.invalidSession, so that we can access the relevant UserStub in a multi-account context
    case ApiClientError.invalidSession, ApiClientError.noToken:
        Task { @MainActor in
            showReauthSheet()
        }
        return true
    case ApiClientError.cancelled, is CancellationError:
        print("Cancellation error")
        return true
    default:
        if (error as NSError).code == NSURLErrorCancelled {
            print("Timeout error")
            return true
        }
        return false
    }
}

@MainActor
private func showReauthSheet() {
    if let user = AppState.main.firstSession.account as? UserAccount,
       !NavigationModel.main.layers.contains(where: { $0.root == .logIn(.reauth(user)) }) {
        NavigationModel.main.openSheet(.logIn(.reauth(user)))
    }
}

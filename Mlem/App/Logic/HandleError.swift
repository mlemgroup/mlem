//
//  HandleError.swift
//  Mlem
//
//  Created by Sjmarf on 18/05/2024.
//

import MlemMiddleware
import SwiftUI

func handleError(
    _ error: Error,
    errorDetails: Binding<ErrorDetails?>? = nil,
    file: StaticString = #fileID,
    function: StaticString = #function,
    line: Int = #line
) {
    #if DEBUG
        print("☠️ ERROR ☠️")
        print("📝 -> \(error.localizedDescription)")
        if let error = error as? ApiClientError {
            print("     \(error.description)")
        }
        print("📂 -> \(file) | \(function) | line: \(line)")
    #endif
    
    switch error {
    // TODO: Modify MlemMiddleware to attach the ApiClient throwing the error to ApiClientError.invalidSession, so that we can access the relevant UserStub in a multi-account context
    case ApiClientError.invalidSession:
        showReauthSheet()
    case ApiClientError.cancelled, is CancellationError:
        print("Cancellation error")
    default:
        if let errorDetails {
            errorDetails.wrappedValue = .init(error: error)
        } else {
            ToastModel.main.add(.error(.init(error: error)))
        }
    }
}

private func showReauthSheet() {
    if let user = AppState.main.firstSession.account as? UserAccount {
        for layer in NavigationModel.main.layers {
            switch layer.path.first {
            case let .logIn(page):
                switch page {
                case .reauth:
                    return
                default:
                    break
                }
            default:
                break
            }
        }
        NavigationModel.main.openSheet(.logIn(.reauth(user)))
    }
}

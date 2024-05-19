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
    toastGroup: String? = nil,
    file: StaticString = #fileID,
    function: StaticString = #function,
    line: Int = #line
) {
    #if DEBUG
        print("☠️ ERROR ☠️")
        print("📝 -> \(error.localizedDescription)")
        print("📂 -> \(file) | \(function) | line: \(line)")
    #endif
    
    switch error {
    // TODO: Modify MlemMiddleware to attach the ApiClient throwing the error to ApiClientError.invalidSession, so that we can access the relevant UserStub in a multi-account context
    case ApiClientError.invalidSession:
        if let user = AppState.main.firstAccount.userStub {
            for layer in NavigationModel.main.layers {
                switch layer.path.first {
                case let .login(page):
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
            NavigationModel.main.openSheet(.login(.reauth(user)))
        }
    default:
        if let errorDetails {
            errorDetails.wrappedValue = .init(error: error)
        } else {
            ToastModel.main.add(.error(.init(error: error)), group: toastGroup)
        }
    }
}

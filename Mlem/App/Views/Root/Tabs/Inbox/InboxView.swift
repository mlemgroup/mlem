//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import MlemMiddleware
import SwiftUI

struct InboxView: View {
    @Environment(NavigationLayer.self) var navigation
    
    let toastGroup: ToastGroup = .init()
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Success") {
                ToastModel.main.add(.success())
            }
            Button("Failure (Grouped)") {
                ToastModel.main.add(.failure(), group: toastGroup)
            }
            Button("Profile") {
                if let userStub = AppState.main.firstAccount.userStub {
                    ToastModel.main.add(.user(userStub))
                }
            }
            Button("Undoable") {
                ToastModel.main.add(
                    .undoable(
                        title: "Unfavorited Community",
                        systemImage: "star.slash.fill",
                        callback: {},
                        color: .blue
                    )
                )
            }
            Button("Error") {
                handleError(ApiClientError.cancelled)
            }
            Button("Open Sheet") {
                navigation.openSheet(.profile)
            }
        }
    }
}

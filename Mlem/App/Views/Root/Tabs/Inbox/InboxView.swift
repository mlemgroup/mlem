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
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Success") {
                ToastModel.main.add(.success())
            }
            Button("Failure") {
                ToastModel.main.add(.failure())
            }
            Button("Profile") {
                ToastModel.main.add(.account(AppState.main.firstAccount.account))
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
            Button("Super Long Text") {
                ToastModel.main.add(.success("Really Super Long Text"))
            }
            Button("Open Sheet") {
                navigation.openSheet(.inbox)
            }
            ToastView(.success("Really super long text"))
        }
    }
}

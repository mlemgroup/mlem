//
//  InboxView.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import LemmyMarkdownUI
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
                ToastModel.main.add(.account(AppState.main.firstSession.account))
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
                handleError(ApiClientError.invalidInput)
            }
            Button("Super Long Text") {
                ToastModel.main.add(.success("Really Super Long Text"))
            }
            Button("Open Sheet") {
                navigation.openSheet(.inbox)
            }
            Button("Open lemmy.world User") {
                navigation.push(
                    .person(PersonStub(
                        api: AppState.main.firstApi,
                        actorId: .init(string: "https://lemmy.world/u/FlyingSquid")!
                    ))
                )
            }
            Button("Search Communities") {
                navigation.openSheet(.communityPicker(callback: { print($0.name) }))
            }
        }
    }
}

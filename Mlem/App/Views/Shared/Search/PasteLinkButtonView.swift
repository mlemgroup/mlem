//
//  PasteLinkButtonView.swift
//  Mlem
//
//  Created by Sjmarf on 20/06/2024.
//

import Dependencies
import MlemMiddleware
import SwiftUI

struct PasteLinkButtonView: View {
    @Environment(\.openURL) private var openURL
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    
    var body: some View {
        Button("Open URL from Clipboard", icon: .general.paste) {
            if let url = UIPasteboard.general.url {
                openURL(url)
                return
                }

            if let string = UIPasteboard.general.string {
                if let handle = try? CommunityHandle(string: string) {
                    navigation.push(.communityStub(.init(api: appState.firstApi, handle: handle)))
                    return
                }
                if let handle = try? PersonHandle(string: string) {
                    navigation.push(.personStub(.init(api: appState.firstApi, handle: handle)))
                    return
                }
                if let url = URL(string: string), UIApplication.shared.canOpenURL(url) {
                    openURL(url)
                    return
                }
            }

            ToastModel.main.add(.failure("Couldn't read URL"))
        }
    }
}

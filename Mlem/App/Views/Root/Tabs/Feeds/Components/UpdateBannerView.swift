//
//  UpdateBannerView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-29.
//

import MlemMiddleware
import SwiftUI
import Theming

struct UpdateBannerView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.palette) var palette
    
    @AppStorage("lastBuildNumber") var lastBuildNumber: String?
    
    @State var isLoading: Bool = false
    
    var body: some View {
        HStack {
            Text("TestFlight updated!")
                .fontWeight(.semibold)
                .foregroundStyle(.themedAccent)
                .padding(.leading, 5)
            Spacer()
            Button(action: submit) {
                Text("What's New?")
                    .padding(.vertical, 4)
                    .opacity(isLoading ? 0 : 1)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .tint(.themedContrastingLabel)
                        }
                    }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedAccent.opacity(0.2))
        // This avoid being partially transparent when context menu is open
        .background(.themedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .quickSwipes(trailing: [
            BasicAction(
                id: "dismissTestFlightUpdatePopup",
                appearance: .init(label: "Dismiss", color: .themedNegative, icon: Icons.close),
                callback: dismiss
            )
        ])
        .contextMenu {
            Button("Dismiss", icon: .general.close) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    dismiss()
                }
            }
        }
    }
    
    func dismiss() {
        lastBuildNumber = Bundle.main.buildVersionNumber
    }
    
    func submit() {
        isLoading = true
        Task {
            do {
                let community: Community2 = try await appState.firstApi.getCommunity(url: URL(string: "https://lemmy.ml/c/mlemapp")!)
                // Assuming the update announcement is pinned, it'll probably be one of these 10.
                var posts = try await community.getPosts(sort: .new, limit: 10).posts.sorted { $0.created > $1.created }
                let announcementPost = posts.first { post in
                    post.creator.isMlemDeveloper && post.title.contains("[ TestFlight Update ]")
                }
                if let announcementPost {
                    navigation.push(.post(announcementPost))
                } else {
                    assertionFailure()
                    navigation.push(.community(community, visitContext: .other))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } catch {
                handleError(error)
                isLoading = false
            }
        }
    }
}

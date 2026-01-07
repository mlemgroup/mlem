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
    
    @AppStorage("lastTestFlightUpdate") var lastTestFlightUpdate: URL?
    
    @State var isLoading: Bool = false
    
    let url: URL
    
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
        lastTestFlightUpdate = url
    }
    
    func submit() {
        isLoading = true
        Task {
            do {
                let announcementPost = try await appState.firstApi.unifiedGetPost(url: url)
                navigation.push(.post(announcementPost))
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

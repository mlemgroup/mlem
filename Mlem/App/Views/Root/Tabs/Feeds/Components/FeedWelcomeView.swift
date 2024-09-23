//
//  FeedWelcomeView.swift
//  Mlem
//
//  Created by Sjmarf on 22/09/2024.
//

import SwiftUI

struct FeedWelcomeView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.showFeedWelcomePrompt) var showWelcomePrompt
    
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            HStack(spacing: Constants.main.standardSpacing) {
                VStack(alignment: .leading) {
                    Text("Welcome to Lemmy!")
                        .fontWeight(.semibold)
                    Text(
                        // swiftlint:disable:next line_length
                        "You are browsing \(appState.firstApi.host ?? "") as a guest. If you'd like to vote or reply, you'll need to log in or sign up."
                    )
                    .font(.footnote)
                }
            }
            .foregroundStyle(palette.accent)
            HStack(spacing: Constants.main.standardSpacing) {
                Button {
                    navigation.openSheet(.logIn(.pickInstance))
                } label: {
                    Text("Log In")
                        .frame(maxWidth: 400)
                        .padding(.vertical, 4)
                }
                Button {
                    navigation.openSheet(.signUp())
                } label: {
                    Text("Sign Up")
                        .frame(maxWidth: 400)
                        .padding(.vertical, 4)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Constants.main.standardSpacing)
        .background(palette.accent.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
        .overlay(alignment: .topTrailing) {
            Button("Dismiss", systemImage: Icons.closeCircleFill) {
                showWelcomePrompt = false
            }
            .symbolRenderingMode(.hierarchical)
            .labelStyle(.iconOnly)
            .fontWeight(.semibold)
            .padding(4)
        }
    }
}

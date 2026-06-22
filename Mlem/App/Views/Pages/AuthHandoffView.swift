//
//  AuthHandoffView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-22.
//

import SwiftUI

struct AuthHandoffView: View {
    @Environment(AppState.self) var appState

    let session: String
    let userHandle: String
    let openedFromInAppBrowser: Bool

    var body: some View {
        VStack {
            Text("Sign In to Canvas")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxHeight: .infinity)

            if let account = appState.firstAccount as? UserAccount {
                accountView(account)
            }

            Button {

            } label: {
                Text("Approve")
                    .fontWeight(.semibold)
                    .foregroundStyle(.themedContrastingLabel)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.themedAccent, in: .capsule)
            }
                
            Button {
                
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.themedPrimary.opacity(0.1), in: .capsule)
            }
        }
        .padding(.horizontal, 16)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func accountView(_ account: UserAccount) -> some View {
        HStack(alignment: .center, spacing: 10) {
            CircleCroppedImageView(account, frame: 40, showProgress: false)
            VStack(alignment: .leading) {
                Text(account.nickname)
                Text("@\(account.host)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, -2)
        }
        .contentShape(.rect)
    }
}

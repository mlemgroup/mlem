//
//  AuthHandoffView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-22.
//

import MlemMiddleware
import SwiftUI

struct AuthHandoffView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    enum Page {
        case askToAuthenticate
        case authenticating
        case error(ErrorDetails)
        case done
    }

    let session: String
    let personHandle: PersonHandle
    let openedFromInAppBrowser: Bool
    let defaultAccount: UserAccount

    @State var chosenAccount: UserAccount?

    @State var page: Page = .askToAuthenticate

    var account: UserAccount {
        chosenAccount ?? defaultAccount
    }
    
    var body: some View {
        VStack {
            switch page {
            case .askToAuthenticate:
                askToAuthenticateView
            case .authenticating:
                VStack {
                    Text("Authenticating...")
                    ProgressView()
                }
            case let .error(details):
                ErrorView(details)
            case .done:
                Text("Done")
            }
        }
        .padding(.horizontal, 16)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var askToAuthenticateView: some View {
        VStack {
            Text("Sign In to Canvas")
                .font(.title)
                .fontWeight(.bold)
            accountView
                .padding(.horizontal, 32)
        }
        .frame(maxHeight: .infinity)

        Button {
            Task {
                await signIn()
            }
        } label: {
            Text("Approve")
                .fontWeight(.semibold)
                .foregroundStyle(.themedContrastingLabel)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(.themedAccent, in: .capsule)
        }
                
        Button {
            dismiss()
        } label: {
            Text("Cancel")
                .fontWeight(.semibold)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(.themedPrimary.opacity(0.1), in: .capsule)
        }
    }

    @ViewBuilder
    var accountView: some View {
        AccountPickerMenu(account: .init(get: { account }, set: { chosenAccount = $0 })) {
            HStack(alignment: .center, spacing: 10) {
                CircleCroppedImageView(account, frame: 40, showProgress: false)
                    .id(account.hashValue)
                VStack(alignment: .leading) {
                    Text(account.nickname)
                    Text("@\(account.host)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, -2)
                Spacer()
                Image(icon: .general.dropDown)
                    .foregroundStyle(.themedSecondary)
                    .fontWeight(.semibold)
                    .padding(.trailing, 5)
            }
            .contentShape(.rect)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.themedPrimary.opacity(0.1), in: .capsule)
        }
    }

    func signIn() async {
        self.page = .authenticating
        do {
            let person = try await account.api.getPerson(handle: personHandle)
            try await account.api.createMessage(
                personId: person.id,
                content: "\(session) \(String(localized: "Sent by Mlem to sign in to Canvas"))"
            )
            self.page = .done
        } catch {
            self.page = .error(.init(error: error))
        }
    }
}

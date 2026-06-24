//
//  AuthHandoffView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-22.
//

import Haptics
import MlemMiddleware
import SwiftUI

struct AuthHandoffView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager

    @Environment(\.dismiss) var dismiss

    enum Page: Equatable {
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
                errorView(details)
            case .done:
                doneView
            }
        }
        .padding(.horizontal, 16)
        .interactiveDismissDisabled(![.askToAuthenticate, .done].contains(page))
        .animation(.easeOut(duration: 0.2), value: page)
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

        Button("Approve") {
            Task {
                await signIn()
            }
        }
        .buttonStyle(CapsuleButtonStyle(isProminent: true))
                
        Button("Cancel") {
            dismiss()
        }
        .buttonStyle(CapsuleButtonStyle(isProminent: false))
    }

    @ViewBuilder
    func errorView(_ details: ErrorDetails) -> some View {
        VStack {
            ErrorView(details)
                .frame(maxHeight: .infinity)
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(CapsuleButtonStyle(isProminent: false))
        }
    }

    @ViewBuilder
    var doneView: some View {
        if openedFromInAppBrowser {
            doneCheckmark
                .frame(maxHeight: 200)
                .transition(.opacity.combined(with: .scale))
        } else {
            VStack {
                doneCheckmark
                    .frame(maxHeight: 50)
                    .transition(.opacity.combined(with: .scale))
                    .padding()
                Text("Signed In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Please return to Canvas.")
            }
            .frame(maxHeight: .infinity)
            Button("Dismiss") {
                dismiss()
            }
            .buttonStyle(CapsuleButtonStyle(isProminent: false))
        }
    }

    @ViewBuilder
    var doneCheckmark: some View {
        Image(icon: .general.success)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolVariant(.circle.fill)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.themedPositive)
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
            hapticManager.play(haptic: .success, tier: .low)
            if openedFromInAppBrowser {
                withAnimation(.bouncy(duration: 0.5, extraBounce: 0.1)) {
                    self.page = .done
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    dismiss()
                }
            } else {
                self.page = .done
            }
        } catch {
            self.page = .error(.init(error: error))
        }
    }
}

private struct CapsuleButtonStyle: ButtonStyle {
    let isProminent: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundStyle(isProminent ? .themedContrastingLabel : .themedPrimary)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(isProminent ? .themedAccent : .themedPrimary.opacity(0.1), in: .capsule)
    }
}

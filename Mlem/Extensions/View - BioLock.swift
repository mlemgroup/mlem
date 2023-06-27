//
//  View - BioLock.swift
//  Mlem
//
//  Created by tht7 on 24/06/2023.
//

import Foundation
import SwiftUI
import LocalAuthentication

struct HandleAccountSecurity: ViewModifier {
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @EnvironmentObject var appState: AppState
    let account: SavedAccount?

    @State var context = LAContext()

    func body(content: Content) -> some View {
        if let account = account {
            if accountsTracker.accountPreferences[account.id]?.requiresSecurity == true {
                ZStack {
                    content
                    if appState.locked {
                        // security lock
                        Color.clear.background(.thickMaterial)
                        VStack {
                            Image(systemName: "lock")
                            Text("Locked- tap here to unlock")
                        }
                        .onTapGesture {
                            Task(priority: .userInitiated) {
                                await unlock()
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            print("Will become active")
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                Task {
                                    await unlock()
                                }
                            }
                        }
                    }
                }
            } else {
                content
            }
        } else {
            content
        }
    }

    func unlock() async {
        var error: NSError?
        let reason = "Unlock your account"
        // Check for biometric authentication
        // permissions
        let permissions = LAContext().canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )

        if permissions {
            do {
                if try await LAContext().evaluatePolicy(
                    // .deviceOwnerAuthentication allows
                    // biometric or passcode authentication
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                ) {
                    await MainActor.run {
                        withAnimation {
                            appState.locked = false
                        }
                    }
                }
            } catch {
                print(String(describing: error))
            }
        } else {
            print(String(describing: error))
            // Handle permission denied or error
        }
    }
}

extension View {
    func handleAccountSecurity(account: SavedAccount?) -> some View {
        modifier(HandleAccountSecurity(account: account))
    }
}

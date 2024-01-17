//
//  AppLockView.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import Dependencies
import LocalAuthentication
import SwiftUI

struct AppLockView: View {
    @Dependency(\.accountsTracker) var accountsTracker

    @ObservedObject var biometricUnlock: BiometricUnlock
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(\.setAppFlow) private var setFlow
    
    @AppStorage("appLock") var appLock: AppLock = .disabled
    
    @State var presentError: Bool = false
    @State var isAuthenticating = false

    var body: some View {
        @State var logoOffset: CGFloat = 0

        VStack(spacing: 50) {
            LogoView()
                .frame(width: 150, height: 150)
                .animation(.spring(), value: isAuthenticating)
                .offset(y: isAuthenticating ? 0 : 300)
            Group {
                Button {
                    authenticate()
                } label: {
                    HStack {
                        Spacer()
                        Text("Unlock Mlem")
                            .bold()
                        Spacer()
                    }
                    .frame(width: 200)
                    .padding(15)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onAppear {
            authenticate()
        }
        .alert(isPresented: $presentError, content: {
            Alert(
                title: Text("Error"),
                message: Text("Unable to unlock. Please check FaceID permissions and try again."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    func authenticate() {
        isAuthenticating = true
        biometricUnlock.requestAuthentication { result in
            isAuthenticating = false
            if case .success = result, let account = accountsTracker.defaultAccount {
                setFlow(.account(account))
            } else if case .failure = result {
                presentError = true
            }
        }
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

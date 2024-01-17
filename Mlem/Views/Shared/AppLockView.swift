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
    @State var alertMessage: String = ""

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
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        })
    }
    
    func authenticate() {
        isAuthenticating = true
        biometricUnlock.requestAuthentication { result in
            isAuthenticating = false
            switch result {
            case .success:
                if let account = accountsTracker.defaultAccount {
                    setFlow(.account(account))
                }
            case let .failure(error):
                alertMessage = error.localizedDescription
                presentError = true
            }
        }
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

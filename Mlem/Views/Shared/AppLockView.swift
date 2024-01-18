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
    @Environment(\.scenePhase) var phase
    
    @AppStorage("appLock") var appLock: AppLock = .disabled
    
    @State var isErrorVisible: Bool = false
    @State var isButtonHidden = true
    @State var isAuthenticating = false
    @State var alertMessage: String = ""
    var hasDynamicIsland = UIDevice.current.hasDynamicIsland

    var body: some View {
        ZStack {
            LogoView()
                .frame(width: 150, height: 150)
                .animation(.spring, value: isAuthenticating)
                .offset(y: isAuthenticating && !hasDynamicIsland ? -250 : 0)
                .opacity((isAuthenticating || biometricUnlock.isUnlocked) && hasDynamicIsland ? 0 : 1)
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
            .opacity(isButtonHidden ? 0 : 1)
        }
        .onAppear {
            if phase == .active {
                authenticate()
            }
        }
        .alert(isPresented: $isErrorVisible, content: {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        })
        .onChange(of: phase) { phase in
            if phase == .active, isButtonHidden {
                authenticate()
            }
        }
    }
    
    func authenticate() {
        isAuthenticating = true
        isButtonHidden = true
        biometricUnlock.requestAuthentication { result in
            isAuthenticating = false
            switch result {
            case .success: return
            case let .failure(error):
                alertMessage = error.localizedDescription
                isErrorVisible = (phase == .active) // only display when app is visible
                isButtonHidden = false
            }
        }
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

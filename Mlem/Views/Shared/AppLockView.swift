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
    
    @EnvironmentObject var appState: AppState
    @Environment(\.setAppFlow) private var setFlow
    
    @AppStorage("appLock") var appLock: AppLock = .disabled
    
    @State var presentError: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: Icons.faceID)
                .resizable()
                .frame(width: 150, height: 150)
            
            Button {
                biometricUnlock.requestAuthentication { result in
                    if case .success = result, let account = accountsTracker.defaultAccount {
                        print("SET ACCOUNT FLOW YO 2")
                        setFlow(.account(account))
                    } else if case .failure = result {
                        presentError = true
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Unlock now")
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
        .onAppear {
            biometricUnlock.requestAuthentication { result in
                DispatchQueue.main.async {
                    if case .success = result, let account = accountsTracker.defaultAccount {
                        setFlow(.account(account))
                    } else if case .failure = result {
                        presentError = true
                    }
                }
            }
        }
        .alert(isPresented: $presentError, content: {
            Alert(
                title: Text("Error"),
                message: Text("Unable to unlock. Please check FaceID permissions."),
                dismissButton: .default(Text("OK"))
            )
        })
        .onChange(of: scenePhase) { phase in
            if phase == .background, appLock != .disabled {
                Task {
                    await BiometricUnlockState().setUnlockStatus(isUnlocked: false)
                }
            }
        }
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

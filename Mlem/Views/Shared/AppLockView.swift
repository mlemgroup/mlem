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
    
    @EnvironmentObject var appState: AppState
    @Environment(\.setAppFlow) private var setFlow
    
    @State var presentError: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: Icons.faceID)
                .resizable()
                .frame(width: 150, height: 150)
            
            Button {
                biometricUnlock.requestAuthentication { isEnabled, _ in
//                    print("APP LOCK STATUS END YO 5: \($biometricUnlock.isUnlocked)")
                    if isEnabled, let account = accountsTracker.defaultAccount {
                        print("SET ACCOUNT FLOW YO 2")
                        setFlow(.account(account))
                    }
                    presentError = !isEnabled
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
            biometricUnlock.requestAuthentication { isEnabled, _ in
                DispatchQueue.main.async {
//                        print("APP LOCK STATUS END YO 6: \($biometricUnlock.isUnlocked)")
                    if isEnabled, let account = accountsTracker.defaultAccount {
//                            biometricUnlock.isUnlocked = isEnabled
//                            print("SET ACCOUNT FLOW YO: isUnlocked:\($biometricUnlock.isUnlocked)")
                        setFlow(.account(account))
                    }
                        
                    presentError = !isEnabled
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
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

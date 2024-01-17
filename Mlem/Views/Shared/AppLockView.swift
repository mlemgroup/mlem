//
//  AppLockView.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import LocalAuthentication
import SwiftUI

struct AppLockView: View {
    @ObservedObject var biometricUnlock: BiometricUnlock
    @Environment(\.dismiss) private var dismiss
    
    @State var presentError: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: Icons.faceID)
                .resizable()
                .frame(width: 150, height: 150)
            
            Button {
                biometricUnlock.requestPermissions { isEnabled, _ in
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
            biometricUnlock.requestPermissions { isEnabled, _ in
                presentError = !isEnabled
            }
        }
        .alert(isPresented: $presentError, content: {
            Alert(
                title: Text("Error"),
                message: Text("Unable to enable Applock. Please enable FaceID permissions."),
                dismissButton: .default(Text("OK"))
            )
        })
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

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
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: Icons.faceID)
                .resizable()
                .frame(width: 150, height: 150)
            
            Button {
                biometricUnlock.requestUnlock()
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
            biometricUnlock.requestUnlock()
        }
    }
}

#Preview {
    AppLockView(biometricUnlock: BiometricUnlock())
}

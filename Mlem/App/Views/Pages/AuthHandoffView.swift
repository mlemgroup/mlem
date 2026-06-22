//
//  AuthHandoffView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-22.
//

import SwiftUI

struct AuthHandoffView: View {
    let session: String
    let userHandle: String
    let openedFromInAppBrowser: Bool

    var body: some View {
        VStack {
            Text("Sign In to Canvas")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxHeight: .infinity)
            Button {

            } label: {
                Text("Approve")
                    .fontWeight(.semibold)
                    .foregroundStyle(.themedContrastingLabel)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.themedAccent, in: .capsule)
            }
                
            Button {
                
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.themedPrimary.opacity(0.1), in: .capsule)
            }
        }
        .padding(.horizontal, 16)
        .buttonStyle(.plain)
    }
}

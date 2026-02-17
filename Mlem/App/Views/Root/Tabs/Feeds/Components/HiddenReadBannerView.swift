//
//  HiddenReadBannerView.swift
//  Mlem
//
//  Created on 2026-02-17.
//

import SwiftUI

struct HiddenReadBannerView: View {
    @Setting(\.feed_showRead) var showRead

    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            Text("Looking for something? Read posts are hidden.")
                .font(.subheadline)
                .foregroundStyle(.themedAccent)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: Constants.main.standardSpacing) {
                Button {
                    showRead = true
                } label: {
                    Text("Show Read")
                        .frame(maxWidth: 400)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                Button {
                    onDismiss()
                } label: {
                    Text("Dismiss")
                        .frame(maxWidth: 400)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(Constants.main.standardSpacing)
        .background(.themedAccent.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
    }
}

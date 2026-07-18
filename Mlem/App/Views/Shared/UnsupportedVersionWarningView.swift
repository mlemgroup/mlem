//
//  UnsupportedVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct UnsupportedVersionWarningView: View {
    @Environment(\.dismiss) var dismiss

    let account: any Account

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                UnsupportedVersionDescriptionView(
                    host: account.host,
                    software: account.siteSoftware,
                    offerContinuation: true
                )
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.themedGroupedBackground)
        .onDisappear {
            account.ignoreVersionWarning(true)
        }
        .toolbar {
            CloseButtonToolbarItem()
        }
    }
}

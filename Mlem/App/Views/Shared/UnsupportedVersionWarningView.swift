//
//  UnsupportedVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

struct UnsupportedVersionWarningView: View {
    let account: any Account

    var body: some View {
        ScrollView {
            UnsupportedVersionDescriptionView(
                host: account.host,
                software: account.siteSoftware,
                offerContinuation: true
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.themedGroupedBackground)
        .onDisappear {
            account.ignoreVersionWarning(true)
        }
    }
}

//
//  UnsupportedVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import SwiftUI

struct UnsupportedVersionWarningView: View {
    let account: any Account

    var body: some View {
        VStack {
            Text("Unsupported")
        }
        .onDisappear {
            account.ignoreVersionWarning()
        }
    }
}

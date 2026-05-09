//
//  UnavailableContentInfoView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-05-09.
//

import ComponentViews
import SwiftUI

struct UnavailableContentInfoView: View {
    var body: some View {
        FancyScrollView {
            // swiftlint:disable:next line_length
            Text("This content is no longer available.\n\nIt may have been removed automatically. PieFed purges content 7 days after it is removed.\n\nOr, it may have been purged by an administrator.")
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toolbar {
            CloseButtonToolbarItem()
        }
        .presentationBackgroundInteraction(.enabled)
    }
}

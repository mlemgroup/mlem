//
//  LoginVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

struct LoginVersionWarningView: View {
    let host: String
    let software: SiteSoftware

    var body: some View {
        ScrollView {
            VStack {
                Image(icon: .lemmy.versionSort)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)

                Text("\(host) is unsupported")
                    .font(.title)

                Text(
                    """
                     \(host) is running \(software.label), and Mlem requires \(minimumSoftware.label) or later.

                    Consider choosing another instance, or asking your server administrators to upgrade.

                    You can choose to continue anyway, but some features may not work on this version.
                    """
                )
            }
        }
        .background(.themedSecondaryGroupedBackground)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Continue Anyway") {}
            }
        }
    }

    var minimumSoftware: SiteSoftware {
        .init(
            type: software.type,
            version: software.type.minimumSupportedVersion
        )
    }
}

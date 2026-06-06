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
            VStack(alignment: .leading) {
                Image(systemName: "xmark")
                    .resizable()
                    .symbolVariant(.square.fill)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
                    .foregroundStyle(.themedColorfulAccent(5))
                    .padding(.top, 16)

                Text("\(host) is unsupported")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)

                Text(bodyText)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.themedGroupedBackground)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Continue Anyway") {}
            }
        }
    }

    var bodyText: String {
        """
        \(host) is running \(software.label), and Mlem requires \(minimumSoftware.label) or later.

        Consider choosing another instance, or asking your server administrators to upgrade.

        You can choose to continue anyway, but some features may not work on this version.
        """
    }

    var minimumSoftware: SiteSoftware {
        .init(
            type: software.type,
            version: software.type.minimumSupportedVersion
        )
    }
}

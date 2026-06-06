//
//  LoginVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

struct LoginVersionWarningView: View {
    let content: Content

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

                Text("\(content.host) is unsupported")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 5)
                if let software = content.software {
                    Text(bodyText(software: software))
                }
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

    func bodyText(software: SiteSoftware) -> String {
        var result = String(localized: "\(content.host) is running \(software.label), and Mlem requires \(minimumSoftware(type: software.type).label) or later.")
        result += "\n\n"
        result += .init(localized: "Consider choosing another instance, or asking your server administrators to upgrade.")
        result += "\n\n"
        result += .init(localized: "You can choose to continue anyway, but some features may not work on this version.")
        return result
    }

    func minimumSoftware(type: SiteSoftwareType) -> SiteSoftware {
        .init(
            type: type,
            version: type.minimumSupportedVersion
        )
    }
}

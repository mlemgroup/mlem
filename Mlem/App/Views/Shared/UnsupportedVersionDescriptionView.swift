//
//  UnsupportedVersionDescriptionView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

struct UnsupportedVersionDescriptionView: View {
    let host: String
    let software: SiteSoftware?
    let offerContinuation: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "xmark")
                .resizable()
                .symbolVariant(.square.fill)
                .aspectRatio(contentMode: .fit)
                .frame(height: 70)
                .foregroundStyle(.themedColorfulAccent(5))

            Text("\(host) is unsupported")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            if let software {
                Text(bodyText(software: software))
            }
        }
    }

    func bodyText(software: SiteSoftware) -> String {
        var result = String(localized: """
                                       \(host) is running \(software.label), \
                                       and Mlem requires \(minimumSoftware(type: software.type).label) or later.
                                       """)
        result += "\n\n"
        result += .init(localized: "Consider choosing another instance, or asking your server administrators to upgrade.")
        if offerContinuation {
            result += "\n\n"
            result += .init(localized: "You can choose to continue anyway, but some features may not work on this version.")
        }
        return result
    }

    func minimumSoftware(type: SiteSoftwareType) -> SiteSoftware {
        .init(
            type: type,
            version: type.minimumSupportedVersion
        )
    }
}

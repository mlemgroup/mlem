//
//  LoginVersionWarningView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-06.
//

import MlemMiddleware
import SwiftUI

struct LoginVersionWarningView: View {
    @Environment(\.navigation) var navigation

    let content: Content

    var body: some View {
        ScrollView {
            UnsupportedVersionDescriptionView(
                host: content.host,
                software: content.software,
                offerContinuation: content.instance != nil
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.themedGroupedBackground)
        .toolbar {
            if let instance = content.instance {
                ToolbarItem(placement: .bottomBar) {
                    Button("Continue Anyway") {
                        navigation?.push(.logIn(.instance(instance)))
                    }
                }
            }
        }
    }
}

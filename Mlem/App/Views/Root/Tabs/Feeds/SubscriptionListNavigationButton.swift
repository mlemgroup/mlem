//
//  SubscriptionListNavigationButton.swift
//  Mlem
//
//  Created by Sjmarf on 19/09/2024.
//

import ComponentViews
import SwiftUI

struct SubscriptionListNavigationButton<Content: View>: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.sidebarPresentationMode) var sidebarPresentationMode

    let destination: NavigationPage
    let withPadding: Bool
    @ViewBuilder var label: () -> Content
    
    init(
        _ destination: NavigationPage,
        withPadding: Bool,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.destination = destination
        self.withPadding = withPadding
        self.label = label
    }
    
    var body: some View {
        Button {
            navigation.popToRoot()
            navigation.replace(destination)
        } label: {
            Group {
                if sidebarPresentationMode == .single {
                    FormChevron { label() }
                } else {
                    label()
                }
            }
            .padding(.horizontal, withPadding ? 16 : 0)
        }
        .buttonStyle(.empty)
    }
}

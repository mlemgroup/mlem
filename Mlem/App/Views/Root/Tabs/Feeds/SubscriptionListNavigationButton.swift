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
    @ViewBuilder var label: () -> Content
    
    init(_ destination: NavigationPage, @ViewBuilder label: @escaping () -> Content) {
        self.destination = destination
        self.label = label
    }
    
    var body: some View {
        Button {
            navigation.popToRoot()
            navigation.replace(destination)
        } label: {
            if sidebarPresentationMode == .single {
                FormChevron { label() }
            } else {
                label()
            }
        }
        .buttonStyle(.empty)
    }
}

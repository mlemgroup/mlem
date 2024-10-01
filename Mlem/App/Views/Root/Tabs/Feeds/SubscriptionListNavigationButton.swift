//
//  SubscriptionListNavigationButton.swift
//  Mlem
//
//  Created by Sjmarf on 19/09/2024.
//

import SwiftUI

struct SubscriptionListNavigationButton<Content: View>: View {
    @Environment(NavigationLayer.self) var navigation
    let destination: NavigationPage
    @ViewBuilder var label: () -> Content
    
    init(_ destination: NavigationPage, @ViewBuilder label: @escaping () -> Content) {
        self.destination = destination
        self.label = label
    }
    
    var body: some View {
        MultiplatformView(phone: {
            NavigationLink(destination, label: label)
        }, pad: {
            Button(action: {
                navigation.root = destination
            }, label: label)
                .buttonStyle(.empty)
        })
    }
}

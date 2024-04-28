//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

enum NavigationPage: Hashable {
    case page1
    case page2
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .page1:
            Page1()
        case .page2:
            Page2()
        }
    }
    
    var hasNavigationStack: Bool { false }
}

private struct Page1: View {
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        VStack {
            Text("Page 1")
            Button("Go to page 2") {
                navigation.push(.page2)
            }
            Button("Open sheet") {
                navigation.openSheet(.page2, hasNavigationStack: true)
            }
        }
    }
}

private struct Page2: View {
    @Environment(NavigationLayer.self) var navigation
    
    var body: some View {
        VStack {
            Text("Page 2")
            Button("Go to page 1") {
                navigation.push(.page1)
            }
            Button("Open sheet") {
                navigation.openSheet(.page1, hasNavigationStack: true)
            }
        }
    }
}

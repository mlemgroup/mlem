//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

extension NavigationPage {
    var presentationDetents: Set<PresentationDetent> {
        switch self {
        case .selectText: [.medium]
        case .actionSheet: [.medium, .large]
        case .externalApiInfo: [.medium]
        case .rulesList: [.medium, .large]
        case .quickSwitcher: [.medium, .large]
        case .shareInstancePicker: []
        default: [.large]
        }
    }

    var fitDetentEnabled: Bool {
        switch self {
        case .shareInstancePicker: true
        default: false
        }
    }
}

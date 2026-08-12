//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import ComponentViews
import SwiftUI

extension NavigationPage {
    // Return `nil` if you want the view itself to handle detents, rather than
    // that it being handled by the navigation system. 
    var presentationDetentConfiguration: NavigationDetentConfiguration? {
        switch self {
        case .selectText, .unavailableContentInfo, .authHandoff: .only(.medium)
        case .actionSheet: .init([.medium, .large], default: .medium)
        case .externalApiInfo: .only(.medium)
        case .rulesList: .init([.medium, .large], default: .medium)
        case .quickSwitcher: .init([.medium, .large], default: .medium)
        case .shareInstancePicker: .only(.fit)
        case .remove, .denyApplication, .purge, .report, .editCommunity,
            .createComment, .createPost, .ban: nil
        default: .only(.large)
        }
    }

    var fitDetentEnabled: Bool {
        switch self {
        case .shareInstancePicker: true
        default: false
        }
    }
}

struct NavigationDetentConfiguration {
    enum Detent {
        case medium, large, fit

        func presentationDetent() -> PresentationDetent? {
            switch self {
            case .medium: .medium
            case .large: .large
            case .fit: nil
            }
        }
    }

    let detents: Set<Detent>
    let `default`: Detent

    init(_ detents: Set<Detent>, default default_: Detent) {
        self.detents = detents
        self.default = default_
        assert(detents.contains(default_))
    }

    static func only(_ detent: Detent) -> Self {
        .init([detent], default: detent)
    }
}

private extension Set<NavigationDetentConfiguration.Detent> {
    func presentationDetents() -> Set<PresentationDetent> {
        .init(lazy.compactMap { $0.presentationDetent() })
    }
}

extension View {
    @ViewBuilder
    func presentationDetents(
        configuration: NavigationDetentConfiguration,
        selection: Binding<PresentationDetent>
    ) -> some View {
        presentationDetentFitsContent(
            fitDetentEnabled: configuration.detents.contains(.fit),
            configuration.detents.presentationDetents(),
            selection: selection
        )
    }
}

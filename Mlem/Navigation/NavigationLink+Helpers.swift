//
//  NavigationLink+Helpers.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-08.
//

import SwiftUI

extension NavigationLink where Destination == Never {
    
    /// Convenience initializer.
    init(_ route: AppRoute, @ViewBuilder label: () -> Label) {
        self = .init(value: route, label: label)
    }
}

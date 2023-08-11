//
//  Comments.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-03.
//

import SwiftUI

internal extension Animation {
    
    /// Animation for expanding or collapsing a comment and its child comments.
    static func showHideComment(_ collapse: Bool) -> Animation {
        let standard = (0.4, 1.0, collapse ? 0.25 : 0.3)
        let animationValues = standard
        return .interactiveSpring(
            response: animationValues.0,
            dampingFraction: animationValues.1,
            blendDuration: animationValues.2)
    }
}

internal extension AnyTransition {
    
    static func markdownView() -> AnyTransition {
        .opacity
    }
    
    static func commentView() -> AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }
}

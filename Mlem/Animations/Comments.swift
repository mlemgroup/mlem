//
//  Comments.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-03.
//

import SwiftUI

internal extension Animation {
    
    /// Animation for expanding or collapsing a comment and its child comments.
    static func showHideComment() -> Animation {
        let standard = (0.4, 1.0, 0.25)
        /// I like this =)
//        let quick = (0.2, 1.0, 0.25)
        /// Even nicer =P
//        let quick = (0.225, 1.0, 0.275)
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
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        )
        
        // I like this: Parent comment has simple opacity collapse animation, while child comments slide out to the side.
//        .asymmetric(
//            insertion: .move(edge: .leading),
//            removal: .move(edge: .trailing)
//        )
    }
}

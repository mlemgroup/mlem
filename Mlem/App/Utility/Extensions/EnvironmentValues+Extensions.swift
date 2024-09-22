//
//  EnvironmentValues+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 19/09/2024.
//

import MlemMiddleware
import SwiftUI

extension EnvironmentValues {
    @Entry var postContext: (any Post1Providing)?
    @Entry var commentContext: (any Comment1Providing)?
    @Entry var communityContext: (any Community1Providing)?
    
    @Entry var parentFrameWidth: CGFloat = .zero
    @Entry var isRootView: Bool = false
}

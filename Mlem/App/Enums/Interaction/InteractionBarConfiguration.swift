//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Actions
import Foundation
import Icons
import MlemMiddleware
import SwiftUI

protocol InteractionBarConfiguration {
    associatedtype ActionType: LegacyActionTypeProviding
    typealias Item = LegacyInteractionBarItem<ActionType>
}

struct MockReadoutAppearance {
    let icon: Icon
    let label: String
}

//
//  Animations.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-29.
//

import SwiftUI
import UIKit

// https://stackoverflow.com/a/72973172
/// Disables animations on the given action
func withoutAnimation(action: @escaping () -> Void) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    transaction.animation = nil
    UIView.setAnimationsEnabled(false)
    transaction.addAnimationCompletion {
        UIView.setAnimationsEnabled(true)
    }
    withTransaction(transaction) {
        action()
    }
}

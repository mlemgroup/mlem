//
//  ResponsiveTextField+EnvironmentValues.swift
//  TextField
//
//  Created by Luke Redpath on 14/03/2021.
//

import CombineSchedulers
import SwiftUI

// MARK: - Environment Keys

private extension ResponsiveTextField {
    struct KeyboardReturnTypeKey: EnvironmentKey {
        static let defaultValue: UIReturnKeyType = .default
    }

    struct FontKey: EnvironmentKey {
        static let defaultValue: UIFont = .preferredFont(forTextStyle: .body)
    }

    struct PlaceholderColorKey: EnvironmentKey {
        static let defaultValue: UIColor = .placeholderText
    }

    struct TextColorKey: EnvironmentKey {
        static let defaultValue: UIColor = .black
    }

    struct TextAlignmentKey: EnvironmentKey {
        static let defaultValue: NSTextAlignment = .natural
    }

    struct FirstResponderDemandKey: EnvironmentKey {
        static let defaultValue: FirstResponderDemand? = nil
    }

    struct ResponderSchedulerKey: EnvironmentKey {
        static let defaultValue: AnySchedulerOf<RunLoop> = .main
    }
}

// MARK: - Environment Values

extension EnvironmentValues {
    var keyboardReturnKeyType: UIReturnKeyType {
        get { self[ResponsiveTextField.KeyboardReturnTypeKey.self] }
        set { self[ResponsiveTextField.KeyboardReturnTypeKey.self] = newValue }
    }

    var textFieldFont: UIFont {
        get { self[ResponsiveTextField.FontKey.self] }
        set { self[ResponsiveTextField.FontKey.self] = newValue }
    }

    var textFieldPlaceholderColor: UIColor {
        get { self[ResponsiveTextField.PlaceholderColorKey.self] }
        set { self[ResponsiveTextField.PlaceholderColorKey.self] = newValue }
    }

    var textFieldTextColor: UIColor {
        get { self[ResponsiveTextField.TextColorKey.self] }
        set { self[ResponsiveTextField.TextColorKey.self] = newValue }
    }

    var textFieldTextAlignment: NSTextAlignment {
        get { self[ResponsiveTextField.TextAlignmentKey.self] }
        set { self[ResponsiveTextField.TextAlignmentKey.self] = newValue }
    }

    var firstResponderStateDemand: FirstResponderDemand? {
        get { self[ResponsiveTextField.FirstResponderDemandKey.self] }
        set { self[ResponsiveTextField.FirstResponderDemandKey.self] = newValue }
    }

    public var responderScheduler: AnySchedulerOf<RunLoop> {
        get { self[ResponsiveTextField.ResponderSchedulerKey.self] }
        set { self[ResponsiveTextField.ResponderSchedulerKey.self] = newValue }
    }
}

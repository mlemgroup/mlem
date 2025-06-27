//
//  StandardEditActionHandling.swift
//

import UIKit

/// Defines all of the standard editing actions that can be performed.
///
/// Each action corresponds to a property in `StandardEditActionHandling`.
///
public enum StandardEditAction: Equatable, CaseIterable {
    case cut
    case copy
    case paste
    case delete
    case select
    case selectAll
    case toggleBoldface
    case toggleItalics
    case toggleUnderline
    case makeTextWritingDirectionLeftToRight
    case makeTextWritingDirectionRightToLeft
    case increaseSize
    case decreaseSize
    case updateTextAttributes
}

/// A protocol-witness style implementation of the `UIResponderStandardEditActions`
/// protocol that can be used to override the default behaviour of `UITextField`.
///
/// All of the functions return a `Bool`. Returning `false` to prevent the default behaviour.
///
/// - See Also: `UIResponderStandardEditActions` documentation for more details on
/// what each editing action does.
///
public struct StandardEditActionHandling<Responder: UIResponder> {
    // MARK: - Handling cut, copy and paste commands

    /// A closure that can be used to customise a standard edit action.
    ///
    /// - Parameters:
    ///     - `Responder` - the control that this action is associated with, e.g. the `UITextField`
    ///     - `Any?` - the sender of the action.
    ///
    public typealias StandardEditActionHandler = (Responder, Any?) -> Bool

    public var cut: StandardEditActionHandler?
    public var copy: StandardEditActionHandler?
    public var paste: StandardEditActionHandler?
    public var delete: StandardEditActionHandler?

    // MARK: - Handling selection commands

    public var select: StandardEditActionHandler?
    public var selectAll: StandardEditActionHandler?

    // MARK: - Handling styled text editing

    public var toggleBoldface: StandardEditActionHandler?
    public var toggleItalics: StandardEditActionHandler?
    public var toggleUnderline: StandardEditActionHandler?

    // MARK: - Handling writing direction changes

    public var makeTextWritingDirectionLeftToRight: StandardEditActionHandler?
    public var makeTextWritingDirectionRightToLeft: StandardEditActionHandler?

    // MARK: - Handling size changes

    public var increaseSize: StandardEditActionHandler?
    public var decreaseSize: StandardEditActionHandler?

    // MARK: - Handling other text formatting changes

    public typealias ConversionHandler = ([NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]

    public var updateTextAttributes: ((Responder, ConversionHandler) -> Bool)?

    public init(
        cut: StandardEditActionHandler? = nil,
        copy: StandardEditActionHandler? = nil,
        paste: StandardEditActionHandler? = nil,
        delete: StandardEditActionHandler? = nil,
        select: StandardEditActionHandler? = nil,
        selectAll: StandardEditActionHandler? = nil,
        toggleBoldface: StandardEditActionHandler? = nil,
        toggleItalics: StandardEditActionHandler? = nil,
        toggleUnderline: StandardEditActionHandler? = nil,
        makeTextWritingDirectionLeftToRight: StandardEditActionHandler? = nil,
        makeTextWritingDirectionRightToLeft: StandardEditActionHandler? = nil,
        increaseSize: StandardEditActionHandler? = nil,
        decreaseSize: StandardEditActionHandler? = nil,
        updateTextAttributes: ((Responder, ConversionHandler) -> Bool)? = nil
    ) {
        self.cut = cut
        self.copy = copy
        self.paste = paste
        self.delete = delete
        self.select = select
        self.selectAll = selectAll
        self.toggleBoldface = toggleBoldface
        self.toggleItalics = toggleItalics
        self.toggleUnderline = toggleUnderline
        self.makeTextWritingDirectionLeftToRight = makeTextWritingDirectionLeftToRight
        self.makeTextWritingDirectionRightToLeft = makeTextWritingDirectionRightToLeft
        self.increaseSize = increaseSize
        self.decreaseSize = decreaseSize
        self.updateTextAttributes = updateTextAttributes
    }
}

// MARK: - Supported standard editing actions

extension _UnderlyingTextField {
    // swiftlint:disable:next cyclomatic_complexity
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let supportedActions = supportedStandardEditActions else {
            return super.canPerformAction(action, withSender: true)
        }
        switch action {
        case #selector(cut(_:)):
            return supportedActions.contains(.cut)
        case #selector(copy(_:)):
            return supportedActions.contains(.copy)
        case #selector(paste(_:)):
            return supportedActions.contains(.paste)
        case #selector(select(_:)):
            return supportedActions.contains(.select)
        case #selector(selectAll(_:)):
            return supportedActions.contains(.selectAll)
        case #selector(toggleBoldface(_:)):
            return supportedActions.contains(.toggleBoldface)
        case #selector(toggleItalics(_:)):
            return supportedActions.contains(.toggleItalics)
        case #selector(toggleUnderline(_:)):
            return supportedActions.contains(.toggleUnderline)
        case #selector(makeTextWritingDirectionLeftToRight(_:)):
            return supportedActions.contains(.makeTextWritingDirectionLeftToRight)
        case #selector(makeTextWritingDirectionRightToLeft(_:)):
            return supportedActions.contains(.makeTextWritingDirectionRightToLeft)
        case #selector(increaseSize(_:)):
            return supportedActions.contains(.increaseSize)
        case #selector(decreaseSize(_:)):
            return supportedActions.contains(.decreaseSize)
        case #selector(updateTextAttributes(conversionHandler:)):
            return supportedActions.contains(.updateTextAttributes)
        default:
            // Return the default for any unhandled actions
            return super.canPerformAction(action, withSender: true)
        }
    }
}

// MARK: - Standard editing action handling

extension _UnderlyingTextField {
    typealias EditActionHandling = StandardEditActionHandling<UITextField>
    typealias EditActionHandler = EditActionHandling.StandardEditActionHandler

    /// Performs a standard edit action function, deferring to the original implementation if there is no standard edit action handler.
    ///
    /// If a standard edit action handler has been provided and it implements the specified override, it will call the override and
    /// if the override returns `true`, it will also call the original.
    ///
    /// If a standard edit action handler has been provided and it does not implement the specified override, the original will
    /// be called.
    private func performStandardEditActionHandler(
        sender: Any?,
        original: (Any?) -> Void,
        override: KeyPath<EditActionHandling, EditActionHandler?>
    ) {
        guard let actions = standardEditActionHandler else {
            original(sender)
            return
        }
        if let override = actions[keyPath: override] {
            let callOriginal = override(self, sender)
            if callOriginal { original(sender) }
        } else {
            original(sender)
        }
    }

    override func cut(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.cut($0) },
            override: \.cut
        )
    }

    override func copy(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.copy($0) },
            override: \.copy
        )
    }

    override func paste(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.paste($0) },
            override: \.paste
        )
    }

    override func select(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.select($0) },
            override: \.select
        )
    }

    override func selectAll(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.selectAll($0) },
            override: \.selectAll
        )
    }

    override func toggleBoldface(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.toggleBoldface($0) },
            override: \.toggleBoldface
        )
    }

    override func toggleItalics(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.toggleItalics($0) },
            override: \.toggleItalics
        )
    }

    override func toggleUnderline(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.toggleUnderline($0) },
            override: \.toggleUnderline
        )
    }

    override func makeTextWritingDirectionLeftToRight(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.makeTextWritingDirectionLeftToRight($0) },
            override: \.makeTextWritingDirectionLeftToRight
        )
    }

    override func makeTextWritingDirectionRightToLeft(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.makeTextWritingDirectionRightToLeft($0) },
            override: \.makeTextWritingDirectionRightToLeft
        )
    }

    override func increaseSize(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.increaseSize($0) },
            override: \.increaseSize
        )
    }

    override func decreaseSize(_ sender: Any?) {
        performStandardEditActionHandler(
            sender: sender,
            original: { super.decreaseSize($0) },
            override: \.decreaseSize
        )
    }

    override func updateTextAttributes(conversionHandler: ([NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]) {
        guard let actions = standardEditActionHandler else {
            super.updateTextAttributes(conversionHandler: conversionHandler)
            return
        }
        if let override = actions.updateTextAttributes {
            let callOriginal = override(self, conversionHandler)
            if callOriginal {
                super.updateTextAttributes(conversionHandler: conversionHandler)
            }
        } else {
            super.updateTextAttributes(conversionHandler: conversionHandler)
        }
    }
}

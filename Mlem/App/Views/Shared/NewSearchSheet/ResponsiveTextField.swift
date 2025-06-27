//
//  ResponsiveTextField.swift
//

import Combine
import CombineSchedulers
import SwiftUI
import UIKit

// MARK: - Main Interface

/// A SwiftUI wrapper around UITextField that gives precise control over the responder state.
///
public struct ResponsiveTextField {
    /// The text field placeholder string.
    let placeholder: String?

    /// A binding to the text state that will hold the typed text
    let text: Binding<String>

    /// Enables secure text entry.
    ///
    /// This field can be updated, allowing you to toggle secure entry on and off using
    /// some external state.
    let isSecure: Bool

    /// Can be used to programatically control the text field's first responder state.
    ///
    /// When the binding's wrapped value is set, it will cause the text field to try and become or resign first responder status
    /// either on first initialisation or on subsequent view updates.
    ///
    /// A wrapped value of `nil` indicates there is no demand (or any previous demand has been fulfilled).
    ///
    /// To detect when the text field actually becomes or resigns first responder, pass in a `onFirstResponderStateChanged`
    /// handler.
    var firstResponderDemand: Binding<FirstResponderDemand?>?

    /// Allows for the text field to be configured during creation.
    let configuration: Configuration

    /// Controls whether or not the textfield is enabled, using the SwiftUI environment.
    /// To disable the textfield, you can use the standard SwiftUI `.disabled()`
    /// modifier.
    @Environment(\.isEnabled)
    var isEnabled: Bool

    /// Sets the keyboard return type - use the `.responsiveKeyboardReturnType()` modifier.
    @Environment(\.keyboardReturnKeyType)
    var returnKeyType: UIReturnKeyType

    /// Sets the text field font - use the `.responsiveKeyboardFont()` modifier.
    ///
    /// - Note: if `adjustsFontForContentSizeCategory` is `true`, the font will only be set
    /// to this value once when the underlying text field is first created.
    ///
    @Environment(\.textFieldFont)
    var font: UIFont

    /// Sets the text field placeholder color - use the `.responsiveTextFieldPlaceholderColor()` modifier.
    @Environment(\.textFieldPlaceholderColor)
    var placeholderColor: UIColor

    /// When `true`, configures the text field to automatically adjust its font based on the content size category.
    ///
    /// - Note: When set to `true`, the underlying text field will not respond to changes to the `textFieldFont`
    /// environment variable. If you want to implement your own dynamic/state-driven font changes you should set this
    /// to `false` and handle font size adjustment manually.
    ///
    var adjustsFontForContentSizeCategory: Bool

    /// Sets the text field color - use the `.responsiveTextFieldColor()` modifier.
    @Environment(\.textFieldTextColor)
    var textColor: UIColor

    /// Sets the text field alignment - use the `.textFieldTextAlignemnt()` modifier.
    @Environment(\.textFieldTextAlignment)
    var textAlignment: NSTextAlignment

    @Environment(\.responderScheduler)
    private var responderScheduler: AnySchedulerOf<RunLoop>

    /// A calllback function that will be called whenever the first responder state changes.
    var onFirstResponderStateChanged: FirstResponderStateChangeHandler?

    /// A callback function that will be called when the user taps the keyboard return button.
    /// If this is not set, the textfield delegate will indicate that the return key is not handled.
    var handleReturn: (() -> Void)?

    /// A callback function that will be called when the user deletes backwards.
    ///
    /// Takes a single argument - a `String` - which will be the current text when the user
    /// hits the delete key (but before any deletion occurs).
    ///
    /// If this is an empty string, it indicates that the user tapped delete inside an empty field.
    var handleDelete: ((String) -> Void)?

    /// A callback function that can be used to control whether or not text should change.
    ///
    /// Takes two `String` arguments - the text prior to the change and the new text if
    /// the change is permitted.
    ///
    /// Return `true` to allow the change or `false` to prevent the change.
    var shouldChange: ((String, String) -> Bool)?

    /// A list of supported standard editing actions.
    ///
    /// When set, this will override the default standard edit actions for a `UITextField`. Leave
    /// set to `nil` if you only want to support the default actions.
    ///
    /// You can use this property and `standardEditActionHandler` to support both the
    /// range of standard editing actions and how each editing action should be handled.
    ///
    /// If you exclude an edit action from this list, any corresponding action handler set in
    /// any provided `standardEditActionHandler` will not be called.
    var supportedStandardEditActions: Set<StandardEditAction>?

    /// Can be set to provide custom standard editing action behaviour.
    ///
    /// When `nil`, all standard editing actions will result in the default `UITextField` behaviour.
    ///
    /// When set, any overridden actions will be called and if the action handler returns `true`, the
    /// default `UITextField` behaviour will also be called. If the action handler returns `false`,
    /// the default behaviour will not be called.
    ///
    /// If the provided type does not implement a particular editing action, the default `UITextField`
    /// behaviour will be called.
    var standardEditActionHandler: StandardEditActionHandling<UITextField>?

    public init(
        placeholder: String?,
        text: Binding<String>,
        isSecure: Bool = false,
        adjustsFontForContentSizeCategory: Bool = true,
        firstResponderDemand: Binding<FirstResponderDemand?>? = nil,
        configuration: Configuration = .empty,
        onFirstResponderStateChanged: FirstResponderStateChangeHandler? = nil,
        handleReturn: (() -> Void)? = nil,
        handleDelete: ((String) -> Void)? = nil,
        shouldChange: ((String, String) -> Bool)? = nil,
        supportedStandardEditActions: Set<StandardEditAction>? = nil,
        standardEditActionHandler: StandardEditActionHandling<UITextField>? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.firstResponderDemand = firstResponderDemand
        self.isSecure = isSecure
        self.configuration = configuration
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        self.onFirstResponderStateChanged = onFirstResponderStateChanged
        self.handleReturn = handleReturn
        self.handleDelete = handleDelete
        self.shouldChange = shouldChange
        self.supportedStandardEditActions = supportedStandardEditActions
        self.standardEditActionHandler = standardEditActionHandler
    }
}

// MARK: - Managing the first responder state

@MainActor
public struct FirstResponderStateChangeHandler: Sendable {
    /// A closure that will be called when the first responder state changes.
    ///
    /// - Parameters:
    ///     - Bool: A boolean indicating if the text field is now the first responder or not.
    ///
    public var handleStateChange: @Sendable @MainActor (Bool) -> Void

    /// Allows fine-grained control over if the text field should become the first responder.
    ///
    /// This will be called when the text field's `shouldBeginEditing` delegate method is
    /// called and provides a final opportunity to prevent the text field becoming first responder.
    ///
    /// If the responder change was triggered programatically by a `FirstResponderDemand`
    /// and this returns `false` the demand will still be marked as fulfilled and reset to `nil`.
    ///
    public var canBecomeFirstResponder: (@Sendable @MainActor () -> Bool)?

    /// Allows fine-grained control over if the text field should resign the first responder.
    ///
    /// This will be called when the text field's `shouldEndEditing` delegate method is
    /// called and provides a final opportunity to prevent the text field from resigning first responder.
    ///
    /// If the responder change was triggered programatically by a `FirstResponderDemand`
    /// and this returns `false` the demand will still be marked as fulfilled and reset to `nil`.
    ///
    public var canResignFirstResponder: (@Sendable @MainActor () -> Bool)?

    /// Initialises a state change handler with a `handleStateChange` callback.
    ///
    /// Most of the time this is the only callback that you will need to provide so this initialiser
    /// can be called with trailing closure syntax.
    ///
    public init(handleStateChange: @escaping @Sendable @MainActor (Bool) -> Void) {
        self.handleStateChange = handleStateChange
    }

    public init(
        handleStateChange: @escaping @Sendable @MainActor (Bool) -> Void,
        canBecomeFirstResponder: (@Sendable @MainActor () -> Bool)? = nil,
        canResignFirstResponder: (@Sendable @MainActor () -> Bool)? = nil
    ) {
        self.handleStateChange = handleStateChange
        self.canBecomeFirstResponder = canBecomeFirstResponder
        self.canResignFirstResponder = canResignFirstResponder
    }

    func callAsFunction(_ isFirstResponder: Bool) {
        handleStateChange(isFirstResponder)
    }

    /// Returns a new state change handler that wraps the underlying state change handler
    /// in a `withAnimation` closure - this is useful if your state change handler is performing
    /// some state change and you want that change to be animated.
    ///
    /// - Parameters:
    ///     - animation: The animation to perform, or `nil` if you want to explicitly disable animations.
    ///
    public func animation(animation: Animation? = .default) -> Self {
        .init(
            handleStateChange: { isFirstResponder in
                withAnimation(animation) {
                    handleStateChange(isFirstResponder)
                }
            },
            canBecomeFirstResponder: canBecomeFirstResponder,
            canResignFirstResponder: canResignFirstResponder
        )
    }

    /// Returns a new state change handler that scheduldes the callback to the original state change
    /// handler on the given scheduler.
    ///
    /// - Parameters:
    ///     - scheduler: The scheduler to schedule the callback on when the first responder state changes.
    ///     - options: Options to be passed to the scheduler when scheduling.
    ///
    /// This modifier is useful when your first responder state change handler needs to perform some state
    /// mutation that will trigger a new view update and you are programatically triggering the first responder state
    /// change.
    ///
    /// When a text field becomes first responder naturally, e.g. because the user tapped on the text field, it is
    /// safe to perform state changes that perform a view update inside this callback. However, programatic first
    /// responder state changes (where you change the demand state connected to the `firstResponderDemand`
    /// binding passed into `ResponsiveTextField`) happen as part of a view update - i.e. the demand change
    /// will trigger a view update and the `becomeFirstResponder()` call will happen in the `updateUIView`
    /// as part of that view change event.
    ///
    /// This means that the change handler callback will be called as part of the view update and if that change handler
    /// does something to trigger a view update itself, you will receive a runtime warning about the nested view updates.
    ///
    /// To break this loop, `ResponsiveTextField` could ensure that it always wraps its calls to the change handler
    /// on the next runloop tick, or in an async `DispatchQueue` call however this would be a pretty brute-force approach
    /// and would result in an unnecessary queue hop on every callback, even if it wasn't needed.
    ///
    /// Instead, if you are programatically triggering a first responder change and the text field and also triggering a
    /// view update in your state change handler, you can explicitly force that callback to happen after the view update
    /// cycle completes using this method. You can pass in any suitable scheduler, such as `RunLoop.main` or
    /// `DispatchQueue.main`.
    ///
    public func receive<S: Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Self {
        let _scheduler = _Scheduler(scheduler: scheduler, options: options)
        return .init(
            handleStateChange: { isFirstResponder in
                _scheduler.schedule {
                    handleStateChange(isFirstResponder)
                }
            },
            canBecomeFirstResponder: canBecomeFirstResponder,
            canResignFirstResponder: canResignFirstResponder
        )
    }
    
    // Currently whilst DispatchQueue is unchecked sendable, RunLoop is not, and neither are
    // their scheduler options so we need to wrap it in a small unchecked sendable value to
    // cross the sendable boundary.
    private struct _Scheduler<S: Scheduler>: @unchecked Sendable {
        let scheduler: S
        let options: S.SchedulerOptions?
        
        func schedule(_ action: @escaping @Sendable @MainActor () -> Void) {
            scheduler.schedule(options: options) {
                Task { @MainActor in action() }
            }
        }
    }
}

public extension FirstResponderStateChangeHandler {
    /// Returns a change handler that updates a `Bool` binding with the `isFirstResponder`
    /// value whenever it changes.
    ///
    /// - Note: if you want this to trigger an animated change, instead of using the `.animation()`
    /// modifier on `FirstResponderStateChangeHandler`, you can simply pass in an animated
    /// binding instead:
    ///
    ///         onFirstResponderStateChanged: .updates($state.animation())
    ///
    /// - Parameters:
    ///     - binding: A binding to some Boolean state property that should be updated.
    ///
    static func updates(_ binding: Binding<Bool>) -> Self {
        .init { isFirstResponder in
            binding.wrappedValue = isFirstResponder
        }
    }
}

/// Represents a request to change the text field's first responder state.
///
public enum FirstResponderDemand: Equatable, Sendable {
    /// The text field should become first responder on the next view update.
    case shouldBecomeFirstResponder

    /// The text field should resign first responder on the next view update.
    case shouldResignFirstResponder
}

// MARK: - UIViewRepresentable implementation

extension ResponsiveTextField: UIViewRepresentable {
    public func makeUIView(context: Context) -> UITextField {
        let textField = _UnderlyingTextField()
        configuration.configure(textField)
        textField.handleDelete = handleDelete
        textField.supportedStandardEditActions = supportedStandardEditActions
        textField.standardEditActionHandler = standardEditActionHandler
        textField.placeholder = placeholder
        textField.text = text.wrappedValue
        textField.isEnabled = isEnabled
        textField.isSecureTextEntry = isSecure
        textField.font = font
        textField.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
        textField.textColor = textColor
        textField.textAlignment = textAlignment
        textField.returnKeyType = returnKeyType
        
        if let placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }
        
        UIView.performWithoutAnimation {
            textField.becomeFirstResponder()
        }
        
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textFieldTextChanged(_:)),
            for: .editingChanged
        )
        // This stops the text field from expanding if the text overflows the frame width
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(textField: self)
    }

    /// Will update the text view when the containing view triggers a body re-calculation.
    ///
    /// If the first responder state has changed, this may trigger the textfield to become or resign
    /// first responder.
    ///
    public func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.isEnabled = isEnabled
        uiView.isSecureTextEntry = isSecure
        uiView.returnKeyType = returnKeyType
        uiView.text = text.wrappedValue
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment

        if let placeholder {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }

        if !adjustsFontForContentSizeCategory {
            // We should only support dynamic font changes using our own environment
            // value if dynamic type support is disabled otherwise we will override
            // the automatically adjusted font.
            uiView.font = font
        }

        switch (uiView.isFirstResponder, firstResponderDemand?.wrappedValue) {
        case (true, .shouldResignFirstResponder):
            responderScheduler.schedule { uiView.resignFirstResponder() }
        case (false, .shouldBecomeFirstResponder):
            responderScheduler.schedule { uiView.becomeFirstResponder() }
        case (_, nil):
            // If there is no demand then there's nothing to do.
            break
        default:
            // If the current responder state matches the demand then
            // the demand is already fulfilled so we can just reset it.
            resetFirstResponderDemand()
        }
    }

    fileprivate func resetFirstResponderDemand() {
        // Because the first responder demand will trigger a view
        // update when it is set, we need to wait until the next
        // runloop tick to reset it back to nil to avoid runtime
        // warnings.
        responderScheduler.schedule {
            firstResponderDemand?.wrappedValue = nil
        }
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ResponsiveTextField

        @Binding
        var text: String

        init(textField: ResponsiveTextField) {
            self.parent = textField
            self._text = textField.text
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if let canBecomeFirstResponder = parent.onFirstResponderStateChanged?.canBecomeFirstResponder {
                let shouldBeginEditing = canBecomeFirstResponder()
                if !shouldBeginEditing {
                    parent.resetFirstResponderDemand()
                }
                return shouldBeginEditing
            }
            return true
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFirstResponderStateChanged?(true)
            parent.resetFirstResponderDemand()
        }

        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            if let canResignFirstResponder = parent.onFirstResponderStateChanged?.canResignFirstResponder {
                let shouldEndEditing = canResignFirstResponder()
                if !shouldEndEditing {
                    parent.resetFirstResponderDemand()
                }
                return shouldEndEditing
            }
            return true
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFirstResponderStateChanged?(false)
            parent.resetFirstResponderDemand()
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let handleReturn = parent.handleReturn {
                handleReturn()
                return true
            }
            return false
        }

        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let shouldChange = parent.shouldChange {
                let currentText = textField.text ?? ""
                guard let newRange = Range(range, in: currentText) else {
                    return false // when would this conversion fail?
                }
                let newText = currentText.replacingCharacters(in: newRange, with: string)
                return shouldChange(currentText, newText)
            }
            return true
        }

        @objc func textFieldTextChanged(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}

// swiftlint:disable:next type_name
class _UnderlyingTextField: UITextField {
    var handleDelete: ((String) -> Void)?
    var supportedStandardEditActions: Set<StandardEditAction>?
    var standardEditActionHandler: StandardEditActionHandling<UITextField>?

    override func deleteBackward() {
        handleDelete?(text ?? "")
        super.deleteBackward()
    }
}

// MARK: - TextField Configurations

public extension ResponsiveTextField {
    /// Provides a way of configuring the underlying UITextField inside a ResponsiveTextField.
    ///
    /// All ResponsiveTextFields take a configuration which lets you package up common configurations
    /// that you use in your app. Configurations are composable and can be combined to create more
    /// detailed configurations.
    ///
    struct Configuration: Sendable {
        var configure: @MainActor @Sendable (UITextField) -> Void

        public init(configure: @escaping @MainActor @Sendable (UITextField) -> Void) {
            self.configure = configure
        }

        public static func combine(_ configurations: Self...) -> Self {
            combine(configurations)
        }

        public static func combine(_ configurations: [Self]) -> Self {
            .init { textField in
                for configuration in configurations {
                    configuration.configure(textField)
                }
            }
        }
    }
}

// MARK: - Built-in Configuration Values

public extension ResponsiveTextField.Configuration {
    static let empty = Self { _ in }

    static let partOfChain = Self {
        $0.returnKeyType = .next
    }

    static let lastOfChain = Self {
        $0.returnKeyType = .done
    }

    static let autoclears = Self {
        $0.clearsOnBeginEditing = true
    }

    static let email = Self {
        $0.keyboardType = .emailAddress
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
        $0.spellCheckingType = .no
        $0.clearButtonMode = .whileEditing
    }

    static let password = Self {
        $0.keyboardType = .default
        $0.isSecureTextEntry = true
        $0.spellCheckingType = .no
    }
}

// MARK: - View Modifiers

public extension View {
    /// Sets the keyboard return key type on any child `ResponsiveTextField` views.
    func responsiveKeyboardReturnType(_ returnType: UIReturnKeyType) -> some View {
        environment(\.keyboardReturnKeyType, returnType)
    }

    /// Sets the text field font on any child `ResponsiveTextField` views.
    func responsiveTextFieldFont(_ font: UIFont) -> some View {
        environment(\.textFieldFont, font)
    }

    /// Sets the text field text color on any child `ResponsiveTextField` views.
    func responsiveTextFieldTextColor(_ color: UIColor) -> some View {
        environment(\.textFieldTextColor, color)
    }

    /// Sets the text field placeholder text color on any child `ResponsiveTextField` views.
    func responsiveTextFieldPlaceholderColor(_ color: UIColor) -> some View {
        environment(\.textFieldPlaceholderColor, color)
    }

    /// Sets the text field text alignment on any child `ResponsiveTextField` views.
    func responsiveTextFieldTextAlignment(_ alignment: NSTextAlignment) -> some View {
        environment(\.textFieldTextAlignment, alignment)
    }
}

// MARK: - Previews

struct ResponsiveTextField_Previews: PreviewProvider {
    struct TextFieldPreview: View {
        let configuration: ResponsiveTextField.Configuration

        @State
        var text: String = ""

        @State
        var firstResponderDemand: FirstResponderDemand? = .shouldBecomeFirstResponder

        var body: some View {
            ResponsiveTextField(
                placeholder: "Placeholder",
                text: $text,
                firstResponderDemand: $firstResponderDemand,
                configuration: configuration,
                shouldChange: { $1.count <= 10 }
            )
            .fixedSize(horizontal: false, vertical: true)
            .padding()
        }
    }

    static var previews: some View {
        Group {
            TextFieldPreview(configuration: .empty)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Empty Field")

            TextFieldPreview(configuration: .email, text: "example@example.com")
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Email Field")

            TextFieldPreview(configuration: .email, text: "example@example.com")
                .responsiveTextFieldFont(.preferredFont(forTextStyle: .title2))
                .responsiveTextFieldTextColor(.systemBlue)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Text Styling")

            TextFieldPreview(configuration: .email, text: "example@example.com")
                .responsiveTextFieldFont(.preferredFont(forTextStyle: .body))
                .responsiveTextFieldTextColor(.systemBlue)
                .responsiveTextFieldPlaceholderColor(.gray)
                .previewLayout(.sizeThatFits)
                .environment(\.sizeCategory, .extraExtraExtraLarge)
                .previewDisplayName("Dynamic Font Size")

            TextFieldPreview(configuration: .empty, text: "This is some text")
                .responsiveTextFieldTextAlignment(.center)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Custom Alignment")

            TextFieldPreview(configuration: .empty, text: "This is some text")
                .disabled(true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled Field")
        }
    }
    // swiftlint:disable:next file_length
}

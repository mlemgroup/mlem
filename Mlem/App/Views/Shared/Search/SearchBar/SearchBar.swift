//
// Modified version of code taken from the open-source SwiftUIX library. https://github.com/SwiftUIX/SwiftUIX/blob/master/Sources/Intramodular/Search%20Bar/SearchBar.swift
//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(macOS) || targetEnvironment(macCatalyst)

    /// A specialized view for receiving search-related information from the user.
    public struct SearchBar: DefaultTextInputType {
        @Binding fileprivate var text: String
    
//    var customAppKitOrUIKitClass: AppKitOrUIKitSearchBar.Type? // UISearchBar
    
        private let onEditingChanged: (Bool) -> Void
        private let onCommit: () -> Void
        private var isInitialFirstResponder: Bool?
        private var isFocused: Binding<Bool>?
    
        private var placeholder: String?

        #if os(iOS) || targetEnvironment(macCatalyst)
            private var iconImageConfiguration: [UISearchBar.Icon: UIImage] = [:]
        #endif
    
        private var showsCancelButton: Bool?
        private var onCancel: () -> Void = {}
    
        #if os(iOS) || targetEnvironment(macCatalyst)
            private var returnKeyType: UIReturnKeyType?
            private var enablesReturnKeyAutomatically: Bool?
            private var isSecureTextEntry: Bool = false
            private var textContentType: UITextContentType?
            private var keyboardType: UIKeyboardType?
        #endif
    
        public init(
            _ title: some StringProtocol,
            text: Binding<String>,
            onEditingChanged: @escaping (Bool) -> Void = { _ in },
            onCommit: @escaping () -> Void = {}
        ) {
            self.placeholder = String(title)
            self._text = text
            self.onCommit = onCommit
            self.onEditingChanged = onEditingChanged
        }

        public init(
            text: Binding<String>,
            onEditingChanged: @escaping (Bool) -> Void = { _ in },
            onCommit: @escaping () -> Void = {}
        ) {
            self._text = text
            self.onCommit = onCommit
            self.onEditingChanged = onEditingChanged
        }
    }

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    extension SearchBar: UIViewRepresentable {
        public typealias UIViewType = UISearchBar
    
        public func makeUIView(context: Context) -> UIViewType {
            let uiView = _UISearchBar()
        
            uiView.delegate = context.coordinator

            if context.environment.isEnabled {
                DispatchQueue.main.async {
                    if (isInitialFirstResponder ?? isFocused?.wrappedValue) ?? false {
                        uiView.becomeFirstResponder()
                    }
                }
            }

            return uiView
        }
    
        public func updateUIView(_ uiView: UIViewType, context: Context) {
            context.coordinator.base = self
        
            _updateUISearchBar(uiView, environment: context.environment)
        }
    
        func _updateUISearchBar(
            _ uiView: UIViewType,
            environment: EnvironmentValues
        ) {
            uiView.isUserInteractionEnabled = environment.isEnabled

            do {
                uiView.searchTextField.autocorrectionType = environment.disableAutocorrection.map { $0 ? .no : .yes } ?? .default
            
                if let placeholder {
                    uiView.placeholder = placeholder
                }

                for (icon, image) in iconImageConfiguration where uiView.image(
                    for: icon, state: .normal
                ) == nil { // FIXME: This is a performance hack.
                    uiView.setImage(image, for: icon, state: .normal)
                }

                if let showsCancelButton {
                    if uiView.showsCancelButton != showsCancelButton {
                        uiView.setShowsCancelButton(showsCancelButton, animated: true)
                    }
                }
            }
        
            do {
                _assignIfNotEqual(returnKeyType ?? .default, to: &uiView.returnKeyType)
                _assignIfNotEqual(keyboardType ?? .default, to: &uiView.keyboardType)
                _assignIfNotEqual(enablesReturnKeyAutomatically ?? false, to: &uiView.enablesReturnKeyAutomatically)
            }
        
            do {
                if uiView.text != text {
                    uiView.text = text
                }
            
                if !uiView.searchTextField.tokens.isEmpty {
                    uiView.searchTextField.tokens = []
                }
            }

            (uiView as? _UISearchBar)?.isFirstResponderBinding = isFocused

            do {
                // version of below with no responder binding. it's not a pretty hack but it does work
                // note that switching tabs with search selected will result in search still displaying "search for communities and users,"
                // but since the keyboard hides the tab bar that probably won't come up for 99% of users
                if let isFocused, environment.isEnabled {
                    if isFocused.wrappedValue, !uiView.isFirstResponder {
                        DispatchQueue.main.async {
                            uiView.becomeFirstResponder()
                        }
                    } else if !isFocused.wrappedValue, uiView.isFirstResponder {
                        DispatchQueue.main.async {
                            uiView.resignFirstResponder()
                        }
                    }
                }
                
//                if let uiView = uiView as? _UISearchBar, environment.isEnabled {
//                    DispatchQueue.main.async {
//                        if let isFocused, uiView.window != nil {
//                            uiView.isFirstResponderBinding = isFocused
//
//                            if isFocused.wrappedValue, !uiView.isFirstResponder {
//                                uiView.becomeFirstResponder()
//                            } else if !isFocused.wrappedValue, uiView.isFirstResponder {
//                                uiView.resignFirstResponder()
//                            }
//                        }
//                    }
//                }
            }
        }
    
        public class Coordinator: NSObject, UISearchBarDelegate {
            var base: SearchBar
        
            init(base: SearchBar) {
                self.base = base
            }
        
            public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
                base.isFocused?.removeDuplicates().wrappedValue = true
            
                base.onEditingChanged(true)
            }
        
            public func searchBar(_ searchBar: UIViewType, textDidChange searchText: String) {
                base.text = searchText
            }

            public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
                true
            }

            public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
                base.isFocused?.removeDuplicates().wrappedValue = false
            
                base.onEditingChanged(false)
            }
        
            public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                searchBar.endEditing(true)
            
                base.isFocused?.removeDuplicates().wrappedValue = false

                base.onCancel()
            }
        
            public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                searchBar.endEditing(true)
            
                // base.isFocused?.removeDuplicates().wrappedValue = false

                base.onCommit()
            }
        }
    
        public func makeCoordinator() -> Coordinator {
            Coordinator(base: self)
        }
    }

    // MARK: - API

    public extension SearchBar {
        @available(macCatalystApplicationExtension, unavailable)
        @available(iOSApplicationExtension, unavailable)
        @available(tvOSApplicationExtension, unavailable)
        func isInitialFirstResponder(_ isInitialFirstResponder: Bool) -> Self {
            then { $0.isInitialFirstResponder = isInitialFirstResponder }
        }

        @available(macCatalystApplicationExtension, unavailable)
        @available(iOSApplicationExtension, unavailable)
        @available(tvOSApplicationExtension, unavailable)
        func focused(_ isFocused: Binding<Bool>) -> Self {
            then { $0.isFocused = isFocused }
        }
    }

    @available(macCatalystApplicationExtension, unavailable)
    @available(iOSApplicationExtension, unavailable)
    @available(tvOSApplicationExtension, unavailable)
    public extension SearchBar {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
            func placeholder(_ placeholder: String?) -> Self {
                then { $0.placeholder = placeholder }
            }
        #endif
    
        func showsCancelButton(_ showsCancelButton: Bool) -> Self {
            then { $0.showsCancelButton = showsCancelButton }
        }
    
        func onCancel(perform action: @escaping () -> Void) -> Self {
            then { $0.onCancel = action }
        }
    
        func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
            then { $0.returnKeyType = returnKeyType }
        }
    
        func enablesReturnKeyAutomatically(_ enablesReturnKeyAutomatically: Bool) -> Self {
            then { $0.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically }
        }
    
        func textContentType(_ textContentType: UITextContentType?) -> Self {
            then { $0.textContentType = textContentType }
        }
    
        func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
            then { $0.keyboardType = keyboardType }
        }
    }

    // MARK: - Auxiliary

    #if os(iOS) || targetEnvironment(macCatalyst)
        private final class _UISearchBar: UISearchBar {
            var isFirstResponderBinding: Binding<Bool>?
        
            override init(frame: CGRect) {
                super.init(frame: frame)
            }
    
            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
    
            @discardableResult
            override func becomeFirstResponder() -> Bool {
                let result = super.becomeFirstResponder()
        
                isFirstResponderBinding?.wrappedValue = result
        
                return result
            }
    
            @discardableResult
            override func resignFirstResponder() -> Bool {
                let result = super.resignFirstResponder()
        
                isFirstResponderBinding?.wrappedValue = !result
        
                return result
            }
        }
    #endif

    // MARK: - Development Preview -

    #if (os(iOS) && canImport(CoreTelephony)) || targetEnvironment(macCatalyst)
        @available(macCatalystApplicationExtension, unavailable)
        @available(iOSApplicationExtension, unavailable)
        @available(tvOSApplicationExtension, unavailable)
        struct SearchBar_Previews: PreviewProvider {
            static var previews: some View {
                SearchBar("Search...", text: .constant(""))
            }
        }
    #endif
#endif

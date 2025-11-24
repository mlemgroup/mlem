//
//  View+VersionAwareDialog.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-08-23.
//

import SwiftUI

// Acts as a `.alert()` on iOS 26 and above and a `.confirmationDialog()` otherwise
public extension View {
    @ViewBuilder
    func versionAwareDialog(
        _ title: LocalizedStringResource,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> some View
    ) -> some View {
        versionAwareDialog(String(localized: title), isPresented: isPresented, actions: actions) {}
    }
    
    @_disfavoredOverload @ViewBuilder
    func versionAwareDialog(
        _ title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> some View
    ) -> some View {
        if #available(iOS 26, *) {
            alert(title, isPresented: isPresented, actions: actions)
        } else {
            confirmationDialog(title, isPresented: isPresented, actions: actions) {
                Text(title)
            }
        }
    }
    
    @ViewBuilder
    func versionAwareDialog(
        _ title: LocalizedStringResource,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> some View,
        @ViewBuilder message: @escaping () -> some View
    ) -> some View {
        versionAwareDialog(String(localized: title), isPresented: isPresented, actions: actions, message: message)
    }
    
    @_disfavoredOverload @ViewBuilder
    func versionAwareDialog(
        _ title: String,
        isPresented: Binding<Bool>,
        @ViewBuilder actions: @escaping () -> some View,
        @ViewBuilder message: @escaping () -> some View
    ) -> some View {
        if #available(iOS 26, *) {
            alert(title, isPresented: isPresented, actions: actions, message: message)
        } else {
            confirmationDialog(title, isPresented: isPresented, actions: actions, message: message)
        }
    }
}

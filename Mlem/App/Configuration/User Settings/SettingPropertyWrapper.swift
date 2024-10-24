//
//  SettingPropertyWrapper.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//  Adapted from https://fatbobman.com/en/posts/appstorage/
//

import Foundation
import SwiftUI

@propertyWrapper
struct Setting<T>: DynamicProperty {
    @ObservedObject private var defaults: Settings
    private let keyPath: ReferenceWritableKeyPath<Settings, T>
    public init(_ keyPath: ReferenceWritableKeyPath<Settings, T>, defaults: Settings = .main) {
        self.keyPath = keyPath
        self._defaults = .init(wrappedValue: defaults)
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { value in
                defaults[keyPath: keyPath] = value
            }
        )
    }
}

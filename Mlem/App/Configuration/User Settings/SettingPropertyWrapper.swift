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
    private var defaults: CodableSettings
    private let keyPath: ReferenceWritableKeyPath<CodableSettings, T>
    
    public init(_ keyPath: ReferenceWritableKeyPath<CodableSettings, T>, defaults: CodableSettings = Settings.main.codableSettings) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { updateValue(path: keyPath, value: newValue) }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { updateValue(path: keyPath, value: $0) }
        )
    }
    
    private func updateValue(path: ReferenceWritableKeyPath<CodableSettings, T>, value: T) {
        defaults[keyPath: keyPath] = value
        Settings.main.save()
    }
}

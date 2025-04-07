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
    private let keyPath: ReferenceWritableKeyPath<SettingsValues, T>
    
    public init(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        get { Settings.get(keyPath) }
        nonmutating set { Settings.set(keyPath, to: newValue) }
    }
    
    public var projectedValue: Binding<T> {
        Binding(
            get: { Settings.get(keyPath) },
            set: { Settings.set(keyPath, to: $0) }
        )
    }
}

//
//  Configuration.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//  Adapted from https://www.avanderlee.com/swift/appstorage-explained/
//

import Foundation
import SwiftUI

// This has to be ObservableObject because Observed currently does not allow @AppStorage properties without @ObservationIgnored
class Configuration: ObservableObject {
    @AppStorage("post.size") var postSize: PostSize = .compact
    
    // MARK: - Constants

    private let platformConstants: PlatformConstants = .phone
    
    public static let main: Configuration = .init()
}

@propertyWrapper
struct Config<T>: DynamicProperty {
    @ObservedObject private var defaults: Configuration
    private let keyPath: ReferenceWritableKeyPath<Configuration, T>
    public init(_ keyPath: ReferenceWritableKeyPath<Configuration, T>, defaults: Configuration = .main) {
        self.keyPath = keyPath
        self.defaults = defaults
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

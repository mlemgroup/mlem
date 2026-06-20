//
//  Icon.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-23.
//

import SwiftUI

public struct Icon: Hashable {
    public enum Source {
        case system, custom
    }
    
    public enum Variant: Hashable {
        case active, inactive
    }
    
    public enum VariantApplicationStrategy {
        case baseOnly(name: String)
        case fillable(name: String)
        case applySquare(name: String)
        case applyCircle(name: String)
        case custom((Variant?) -> String)
        
        // swiftlint:disable:next cyclomatic_complexity
        func computeImageName(variant: Variant?) -> String {
            switch self {
            case let .baseOnly(name):
                name
            case let .fillable(name):
                switch variant {
                case .active: "\(name).fill"
                default: name
                }
            case let .applySquare(name):
                switch variant {
                case .inactive: "\(name).square"
                case .active: "\(name).square.fill"
                case nil: name
                }
            case let .applyCircle(name):
                switch variant {
                case .active: "\(name).circle.fill"
                case .inactive: "\(name).circle"
                case nil: name
                }
            case let .custom(value):
                value(variant)
            }
        }
    }
    
    let id: UUID
    let variantApplicationStrategy: VariantApplicationStrategy
    let source: Source
    var appliedVariant: Variant?
    
    public init(_ variantApplicationStrategy: VariantApplicationStrategy, source: Source = .system) {
        self.id = .init()
        self.variantApplicationStrategy = variantApplicationStrategy
        self.source = source
    }
    
    public init(_ name: String, source: Source = .system) {
        self.init(.fillable(name: name), source: source)
    }
    
    public func computeImageName() -> String {
        variantApplicationStrategy.computeImageName(variant: appliedVariant)
    }

    public static func baseOnly(_ name: String) -> Self {
        self.init(.baseOnly(name: name))
    }
    
    public static func applySquare(_ name: String) -> Self {
        self.init(.applySquare(name: name))
    }
    
    public static func applyCircle(_ name: String) -> Self {
        self.init(.applyCircle(name: name))
    }
    
    public static func custom(_ customStrategy: @escaping (Variant?) -> String) -> Self {
        self.init(.custom(customStrategy))
    }
    
    private func applyVariant(_ newVariant: Variant) -> Icon {
        var new = self
        new.appliedVariant = newVariant
        return new
    }

    public func representingState(active state: Bool) -> Icon {
        applyVariant(state ? .active : .inactive)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(appliedVariant)
    }
    
    public static func == (lhs: Icon, rhs: Icon) -> Bool {
        lhs.id == rhs.id && lhs.appliedVariant == rhs.appliedVariant
    }
}

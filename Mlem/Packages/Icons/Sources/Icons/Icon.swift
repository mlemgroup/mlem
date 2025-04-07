//
//  Icons.swift
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
        case fill, active, inactive
    }
    
    public enum VariantApplicationStrategy {
        case baseOnly(name: String)
        case applyFill(name: String)
        case applySquare(name: String)
        case applyCircle(name: String)
        case applySquareFill(name: String)
        case applyCircleFill(name: String)
        case custom((Variant?) -> String)
        
        // swiftlint:disable:next cyclomatic_complexity
        func computeImageName(variant: Variant?) -> String {
            switch self {
            case let .baseOnly(name):
                name
            case let .applyFill(name):
                switch variant {
                case .fill, .active: "\(name).fill"
                case .inactive, nil: name
                }
            case let .applySquare(name):
                switch variant {
                case .inactive: "\(name).square"
                case .active: "\(name).square.fill"
                case .fill, nil: name
                }
            case let .applyCircle(name):
                switch variant {
                case .active: "\(name).circle.fill"
                case .inactive: "\(name).circle"
                case .fill, nil: name
                }
            case let .applySquareFill(name):
                switch variant {
                case .inactive: "\(name).square"
                case .active: "\(name).square.fill"
                case .fill: "\(name).fill"
                case nil: name
                }
            case let .applyCircleFill(name):
                switch variant {
                case .inactive: "\(name).circle"
                case .active: "\(name).circle.fill"
                case .fill: "\(name).fill"
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
    
    func computeImageName() -> String {
        variantApplicationStrategy.computeImageName(variant: appliedVariant)
    }
    
    public static func baseOnly(_ name: String) -> Self {
        self.init(.baseOnly(name: name))
    }
    
    public static func applyFill(_ name: String) -> Self {
        self.init(.applyFill(name: name))
    }
    
    public static func applySquare(_ name: String) -> Self {
        self.init(.applySquare(name: name))
    }
    
    public static func applyCircle(_ name: String) -> Self {
        self.init(.applyCircle(name: name))
    }
    
    public static func applySquareFill(_ name: String) -> Self {
        self.init(.applySquareFill(name: name))
    }
    
    public static func applyCircleFill(_ name: String) -> Self {
        self.init(.applyCircleFill(name: name))
    }
    
    public static func custom(_ customStrategy: @escaping (Variant?) -> String) -> Self {
        self.init(.custom(customStrategy))
    }
    
    func applyVariant(_ newVariant: Variant) -> Icon {
        var new = self
        new.appliedVariant = newVariant
        return new
    }
    
    /// A filled variant of the symbol.
    public var fill: Self { applyVariant(.fill) }
    
    /// A variant of the symbol that represents an "on" state.
    public var active: Self { applyVariant(.active) }
    
    /// A variant of the symbol that represents an "off" state.
    public var inactive: Self { applyVariant(.inactive) }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(appliedVariant)
    }
    
    public static func == (lhs: Icon, rhs: Icon) -> Bool {
        lhs.id == rhs.id && lhs.appliedVariant == rhs.appliedVariant
    }
}

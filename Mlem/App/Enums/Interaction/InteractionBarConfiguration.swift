//
//  InteractionConfiguration.swift
//  Mlem
//
//  Created by Sjmarf on 15/08/2024.
//

import Foundation

protocol InteractionBarConfiguration: Codable {
    associatedtype ActionType: ActionTypeProviding
    associatedtype CounterType: CounterTypeProviding
    associatedtype ReadoutType: ReadoutTypeProviding
    
    typealias Item = InteractionConfigurationItem<ActionType, CounterType>
    
    var leading: [Item] { get set }
    var trailing: [Item] { get set }
    var readouts: [ReadoutType] { get set }
    
    static var `default`: Self { get }
    
    init(leading: [Item], trailing: [Item], readouts: [ReadoutType])
}

extension InteractionBarConfiguration {
    /// Convert the `InteractionBarConfiguration` to another type of `InteractionBarConfiguration`. This is done by finding cases with
    /// matching `rawValue` in the new type. If one cannot be found, the item is omitted.
    func convert<T: InteractionBarConfiguration>() -> T {
        .init(
            leading: leading.compactMap { $0.convert() },
            trailing: trailing.compactMap { $0.convert() },
            readouts: readouts.compactMap { .init(rawValue: $0.rawValue) }
        )
    }
}

enum InteractionConfigurationItem<ActionType: ActionTypeProviding, CounterType: CounterTypeProviding>: Codable, Hashable {
    case action(ActionType)
    case counter(CounterType)
    
    static var allCases: [InteractionConfigurationItem] {
        CounterType.allCases.map { .counter($0) } + ActionType.allCases.map { .action($0) }
    }
    
    fileprivate func convert<A: ActionTypeProviding, C: CounterTypeProviding>() -> InteractionConfigurationItem<A, C>? {
        switch self {
        case let .action(action):
            if let value = A(rawValue: action.rawValue) {
                return .action(value)
            } else {
                return nil
            }
        case let .counter(counter):
            if let value = C(rawValue: counter.rawValue) {
                return .counter(value)
            } else {
                return nil
            }
        }
    }
    
    // This is used to determine when an interaction bar configuration is considered "full"
    var score: Int {
        switch self {
        case .action: 1
        case let .counter(counter):
            counter.appearance.leading == nil || counter.appearance.trailing == nil ? 2 : 3
        }
    }
}

protocol ActionTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: ActionAppearance { get }
}

protocol CounterTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: CounterAppearance { get }
}

protocol ReadoutTypeProviding: Codable, CaseIterable, Hashable, RawRepresentable where RawValue == String {
    var appearance: MockReadoutAppearance { get }
}

struct InteractionBarConfigurations: Codable {
    var post: PostBarConfiguration
    var comment: CommentBarConfiguration
    var reply: ReplyBarConfiguration
    
    static var `default`: Self {
        .init(post: .default, comment: .default, reply: .default)
    }
}

struct MockReadoutAppearance {
    let icon: String
    let label: String
}

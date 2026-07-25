//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-13.
//

import Foundation
import Icons
import Theming

public struct ActionAppearance {
    public var labels: ActionLabels
    public var color: ThemedColor
    public var isDestructive: Bool
    public var visibility: ActionVisiblity
    public var prominent: Bool
    
    public init(
        _ title: LocalizedStringResource,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled,
        prominent: Bool = false
    ) {
        self.labels = .basic(.init(title, icon: icon))
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
        self.prominent = prominent 
    }
    
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        icon: Icon,
        color: ThemedColor = .themedAccent,
        isDestructive: Bool = false,
        visibility: ActionVisiblity = .enabled,
        prominent: Bool = false
    ) {
        self.labels = .basic(.init(title, icon: icon))
        self.color = color
        self.isDestructive = isDestructive
        self.visibility = visibility
        self.prominent = prominent
    }
    
    public func withVisibility(_ visibility: ActionVisiblity) -> ActionAppearance {
        var new = self
        new.visibility = visibility
        return new
    }

    public func withProminent(_ value: Bool) -> ActionAppearance {
        var new = self
        new.prominent = prominent
        return new
    }

    public func label(describing type: ActionLabelType) -> ActionLabel {
        switch (self.labels, type) {
        case let (.basic(label), _): label
        case let (.stateChange(current, _), .currentState): current
        case let (.stateChange(_, transition), .stateTransition): transition
        }
    }
}

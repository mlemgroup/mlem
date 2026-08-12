//
//  ActionLabels.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-25.
//

import Foundation

public enum ActionLabels {
    case basic(ActionLabel)
    case stateChange(currentState: ActionLabel, transition: ActionLabel)
}

//
//  ToolbarContent+AxisBehavior.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-31.
//

import SwiftUI

// swiftlint:disable:next type_name
enum ToolbarItemAxisBehavior_ {
    case automatic, horizontalOnly, verticalPreferred

    @available(iOS 27.1, *)
    var swiftUIValue: ToolbarItemAxisBehavior {
        switch self {
        case .automatic: .automatic
        case .horizontalOnly: .horizontalOnly
        case .verticalPreferred: .verticalPreferred
        }
    }
}

extension ToolbarContent {
    @ToolbarContentBuilder
    func axisBehavior_(_ behavior: ToolbarItemAxisBehavior_) -> some ToolbarContent {
        if #available(iOS 27.1, *) {
            self.axisBehavior(behavior.swiftUIValue)
        } else {
            self
        }
    }
}

extension CustomizableToolbarContent {
    @ToolbarContentBuilder
    func axisBehavior_(_ behavior: ToolbarItemAxisBehavior_) -> some CustomizableToolbarContent {
        if #available(iOS 27.1, *) {
            self.axisBehavior(behavior.swiftUIValue)
        } else {
            self
        }
    }
}

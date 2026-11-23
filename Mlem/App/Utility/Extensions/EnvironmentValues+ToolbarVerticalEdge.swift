//
//  EnvironmentValues+ToolbarVerticalEdge.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-31.
//

import SwiftUI

extension EnvironmentValues {
    var toolbarVerticalEdge_: HorizontalEdge? {
        if #available(iOS 27.1, *) {
            toolbarVerticalEdge
        } else {
            nil
        }
    }
}

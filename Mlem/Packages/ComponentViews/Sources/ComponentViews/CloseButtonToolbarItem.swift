//
//  File.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-09-11.
//

import SwiftUI

public struct CloseButtonToolbarItem: ToolbarContent {
    var callback: (() -> Void)?
    
    public init(callback: (() -> Void)? = nil) {
        self.callback = callback
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CloseButtonView(callback: callback)
        }
    }
}

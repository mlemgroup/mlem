//
//  File.swift
//  ComponentViews
//
//  Created by Sjmarf on 2025-09-11.
//

import SwiftUI

public struct CloseButtonToolbarItem: ToolbarContent {
    var ios18Label: CloseButtonView.LabelType
    var callback: (() -> Void)?
    
    public init(
        ios18Label: CloseButtonView.LabelType = .xmark,
        callback: (() -> Void)? = nil
    ) {
        self.ios18Label = ios18Label
        self.callback = callback
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            CloseButtonView(ios18Label: ios18Label, callback: callback)
        }
    }
    
    var placement: ToolbarItemPlacement {
        if #available(iOS 26, *) {
            return .topBarLeading
        } else {
            return .topBarTrailing
        }
    }
}

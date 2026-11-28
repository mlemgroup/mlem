//
//  ContentUnavailableView+Extensions.swift
//  Icons
//
//  Created by mdhiggins on 2026-11-26.
//

import SwiftUI

public extension ContentUnavailableView
where Label == SwiftUI.Label<Text, Image>, Description == Text?, Actions == EmptyView {
    init(_ title: LocalizedStringResource, icon: Icon) {
        self.init(title, systemImage: icon.computeImageName())
    }
}

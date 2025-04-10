//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-10.
//

import SwiftUI

public extension Menu where Label == SwiftUI.Label<Text, Image> {
    nonisolated init(_ title: LocalizedStringResource, icon: Icon, @ViewBuilder content: () -> Content) {
        self.init(title.key, systemImage: icon.computeImageName(), content: content)
    }
}

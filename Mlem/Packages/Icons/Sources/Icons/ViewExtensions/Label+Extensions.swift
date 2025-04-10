//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-10.
//

import SwiftUI

public extension Label where Title == Text, Icon == Image {
    init(_ title: LocalizedStringResource, icon: Icons.Icon) {
        self.init(title.key, systemImage: icon.computeImageName())
    }
}

//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-10.
//

import SwiftUI

public extension Label where Title == Text, Icon == Image {
    init(_ title: LocalizedStringKey, icon: Icons.Icon) {
        switch icon.source {
        case .system:
            self.init(title, systemImage: icon.computeImageName())
        case .custom:
            self.init(title, image: icon.computeImageName())
        }
    }
    
    init(_ title: String, icon: Icons.Icon) {
        switch icon.source {
        case .system:
            self.init(LocalizedStringKey(title), systemImage: icon.computeImageName())
        case .custom:
            self.init(LocalizedStringKey(title), image: icon.computeImageName())
        }
    }
}

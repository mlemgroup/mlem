//
//  PostTag.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-23.
//

import Foundation
import Icons
import SwiftUI
import Theming

func postTag(active: Bool, icon: Icon, color: ThemedColor) -> Text {
    if active {
        Text(Image(icon: icon))
            .foregroundStyle(color)
    } else {
        Text(verbatim: "")
    }
}

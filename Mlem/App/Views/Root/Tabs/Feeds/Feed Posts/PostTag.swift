//
//  PostTag.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-23.
//

import Foundation
import SwiftUI

func postTag(active: Bool, icon: String, color: Color) -> Text {
    if active {
        Text(Image(systemName: icon))
            .foregroundStyle(color)
    } else {
        Text("")
    }
}

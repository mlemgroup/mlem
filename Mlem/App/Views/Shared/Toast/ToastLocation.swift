//
//  ToastLocation.swift
//  Mlem
//
//  Created by Sjmarf on 19/05/2024.
//

import SwiftUI

enum ToastLocation {
    case top, bottom
    
    var edge: Edge {
        switch self {
        case .top:
            .top
        case .bottom:
            .bottom
        }
    }
}

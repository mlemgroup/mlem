//
//  ToastModel.swift
//  Mlem
//
//  Created by Sjmarf on 16/05/2024.
//

import SwiftUI

@Observable
class ToastModel {
    var toasts: [ToastGroup] = .init()
    
    static let main: ToastModel = .init()
}

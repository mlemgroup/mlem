//
//  ToastGroup.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Foundation

@Observable
class ToastGroup: Equatable {
    var activeToast: Toast
    
    init(_ activeToast: Toast) {
        self.activeToast = activeToast
    }
    
    static func == (lhs: ToastGroup, rhs: ToastGroup) -> Bool {
        lhs.activeToast == rhs.activeToast
    }
}

//
//  ToastGroup.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Foundation

@Observable
class ToastGroup {
    var activeToast: Toast
    
    var activeId: UUID = .init()
    
    init(_ activeToast: Toast) {
        self.activeToast = activeToast
    }
}

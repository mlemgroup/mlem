//
//  ToastGroup.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Foundation

@Observable
class ToastGroup: Identifiable, Equatable {
    private(set) var activeToast: Toast?
    
    var activeId: UUID = .init()
    
    init(_ activeToast: Toast? = nil) {
        self.activeToast = activeToast
    }
    
    func setToast(_ toast: Toast) {
        activeToast = toast
        activeId = .init()
    }
    
    static func == (lhs: ToastGroup, rhs: ToastGroup) -> Bool {
        lhs.id == rhs.id
    }
}

//
//  ToastModel.swift
//  Mlem
//
//  Created by Sjmarf on 16/05/2024.
//

import SwiftUI

@Observable
class ToastModel {
    private var groups: [ToastGroup] = .init()
    
    var activeGroup: ToastGroup? { groups.first }
    var activeToast: Toast? { groups.first?.activeToast }
    
    static let main: ToastModel = .init()
    
    func add(_ toast: Toast) {
        groups.append(.init(toast))
    }
    
    func removeFirst() {
        if !groups.isEmpty {
            groups.removeFirst()
        }
    }
}

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
    
    static let main: ToastModel = .init()
    
    func activeGroup(location: ToastLocation) -> ToastGroup? {
        groups.first(where: { $0.location == location })
    }
    
    func add(_ toast: Toast, group: ToastGroup) {
        group.setToast(toast)
        if !groups.contains(group) {
            groups.append(group)
        }
    }
    
    func add(_ toast: Toast, location: ToastLocation? = nil) {
        groups.append(.init(toast, location: location ?? toast.location))
    }
    
    func removeFirst(location: ToastLocation) {
        if !groups.isEmpty {
            if let index = groups.firstIndex(where: { $0.location == location }) {
                groups.remove(at: index)
            }
        }
    }
}

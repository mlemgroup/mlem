//
//  ToastModel.swift
//  Mlem
//
//  Created by Sjmarf on 16/05/2024.
//

import SwiftUI

@Observable
class ToastModel {
    private var toasts: [Toast] = .init()
    
    static let main: ToastModel = .init()
    
    func activeToast(location: ToastLocation) -> Toast? {
        toasts.first(where: { $0.location == location })
    }
    
    func add(_ type: ToastType, location: ToastLocation? = nil, group: String? = nil) {
        let newToast: Toast = .init(
            type: type,
            location: location ?? type.location,
            group: group
        )
        if let group, let index = toasts.firstIndex(where: { $0.group == group }) {
            toasts[index] = newToast
        } else {
            toasts.append(newToast)
        }
    }
    
    func removeFirst(location: ToastLocation) {
        if !toasts.isEmpty {
            if let index = toasts.firstIndex(where: { $0.location == location }) {
                toasts.remove(at: index)
            }
        }
    }
}

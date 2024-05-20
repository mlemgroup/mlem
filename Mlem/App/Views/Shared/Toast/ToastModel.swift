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
    
    func activeToasts(location: ToastLocation) -> [Toast] {
        Array(toasts.lazy.filter { $0.location == location }.prefix(3))
    }
    
    func add(_ type: ToastType, location: ToastLocation? = nil, important: Bool? = nil) {
        let important = important ?? type.important
        let newToast: Toast = .init(
            type: type,
            location: location ?? type.location,
            important: important
        )
        if !important, let index = toasts.firstIndex(where: { !$0.important }) {
            toasts.remove(at: index)
        }
        toasts.append(newToast)
    }
    
    func removeToast(id: UUID) {
        if let index = toasts.firstIndex(where: { $0.id == id }) {
            toasts.remove(at: index)
        }
    }
}

//
//  ToastModel.swift
//  Mlem
//
//  Created by Sjmarf on 16/05/2024.
//

import SwiftUI
import os

@Observable
class ToastModel {
    private let log: Logger = .mlemLogger(subsystem: "Mlem")
    
    private var toasts: [Toast] = .init()
    
    static let main: ToastModel = .init()
    
    func activeToasts(location: ToastLocation) -> [Toast] {
        Array(toasts.filter { $0.location == location }.prefix(3))
    }
    
    @discardableResult
    func add(_ type: ToastType, location: ToastLocation? = nil, important: Bool? = nil) -> UUID {
        let newToast: Toast = .init(
            type: type,
            location: location ?? type.location,
            important: important ?? type.important
        )
        Task { @MainActor in
            if !newToast.important, let index = toasts.firstIndex(
                where: { !$0.important && $0.location == newToast.location }
            ) {
                toasts.remove(at: index)
            }
            toasts.append(newToast)
        }
        return newToast.id
    }
    
    func removeToast(id: UUID) {
        Task { @MainActor in
            if let index = toasts.firstIndex(where: { $0.id == id }) {
                toasts.remove(at: index)
            } else {
                log.debug("No Toast Index")
            }
        }
    }
}

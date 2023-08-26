//
//  Notifier.swift
//  Mlem
//
//  Created by mormaer on 23/07/2023.
//
//

import Foundation

/// An actor to queue notifications which should be presented to the user
actor Notifier {
    
    private var display: (Notifiable) async -> Void
    private var queue = [Notifiable]() {
        didSet {
            guard !isNotifying else { return }
            Task { await notify() }
        }
    }
    
    private var isNotifying = false
    
    init(display: @escaping (Notifiable) async -> Void) {
        self.display = display
    }
    
    func performWithLoader(_ operation: @Sendable @escaping () async -> Void) {
        queue.append(
            Task(priority: .userInitiated, operation: operation)
        )
    }
    
    func add(_ message: NotificationMessage) {
        queue.append(message)
    }
    
    func add(_ notifiable: Notifiable) {
        queue.append(notifiable)
    }
    
    func add(_ notifiables: [Notifiable]) {
        queue.append(contentsOf: notifiables)
    }
    
    private func notify() async {
        guard !queue.isEmpty else {
            isNotifying = false
            return
        }
        
        isNotifying = true
        
        guard let first = queue.first else {
            isNotifying = false
            return
        }
        
        queue.removeFirst()
        await display(first)
        await notify()
    }
}

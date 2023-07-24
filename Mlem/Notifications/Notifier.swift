// 
//  Notifier.swift
//  Mlem
//
//  Created by mormaer on 23/07/2023.
//  
//

import Foundation

actor Notifier {
    
    enum Message: Notifiable {
        case success(String)
        case failure(String)
    }
    
    private var queue = [Notifiable]() {
        didSet {
            guard !isNotifying else { return }
            Task { await notify() }
        }
    }
    
    private var isNotifying = false
    
    func performWithLoader(_ operation: @Sendable @escaping () async -> Void) {
        queue.append(
            Task(priority: .userInitiated, operation: operation)
        )
    }
    
    func add(_ message: Message) {
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
        await NotificationDisplayer.display(first)
        await notify()
    }
}

//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Foundation

class Toast: Identifiable, Hashable {
    let type: ToastType
    let location: ToastLocation
    let important: Bool
    let id: UUID
    
    private var killTask: Task<Void, Error>?
    
    var killTaskStarted: Bool { killTask != nil }
    
    var shouldTimeout: Bool = true {
        didSet {
            if shouldTimeout {
                startKillTask()
            } else {
                killTask?.cancel()
                killTask = nil
            }
        }
    }
    
    init(type: ToastType, location: ToastLocation, important: Bool = false) {
        self.type = type
        self.location = location
        self.important = important
        self.id = .init()
    }
    
    func kill() {
        ToastModel.main.removeToast(id: id)
        killTask?.cancel()
        killTask = nil
    }
    
    func startKillTask() {
        if shouldTimeout {
            killTask?.cancel()
            killTask = Task {
                try await Task.sleep(
                    nanoseconds: UInt64(1_000_000_000 * type.duration)
                )
                self.kill()
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(location)
        hasher.combine(important)
    }
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

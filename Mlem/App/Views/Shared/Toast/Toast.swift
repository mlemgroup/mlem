//
//  Toast.swift
//  Mlem
//
//  Created by Sjmarf on 15/05/2024.
//

import Foundation

struct Toast: Identifiable, Equatable, Hashable {
    let type: ToastType
    let location: ToastLocation
    let group: String?
    let id: UUID?
    
    init(type: ToastType, location: ToastLocation, group: String?) {
        self.type = type
        self.location = location
        self.group = group
        self.id = .init()
    }
}

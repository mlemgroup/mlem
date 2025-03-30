//
//  Captcha.swift
//
//
//  Created by Sjmarf on 06/09/2024.
//

import Foundation

public struct Captcha: Identifiable {
    public let id: UUID
    public let imageData: Data
    
    init(id: UUID, imageData: Data) {
        self.id = id
        self.imageData = imageData
    }
}

// 
//  ContextualError.swift
//  Mlem
//
//  Created by mormaer on 09/07/2023.
//  
//

import Foundation

struct ContextualError: Error, Equatable {
    
    let title: String?
    let message: String?
    let underlyingError: EquatableError
    
    init(title: String? = nil, message: String? = nil, underlyingError: Error) {
        self.title = title
        self.message = message
        self.underlyingError = underlyingError.toEquatableError()
    }
}

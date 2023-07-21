// 
//  ContextualError.swift
//  Mlem
//
//  Created by mormaer on 09/07/2023.
//  
//

import Foundation

struct ContextualError: Error, Equatable {
    
    enum PreferredStyle {
        case alert
        case toast
    }
    
    let title: String?
    let message: String?
    let style: PreferredStyle
    let underlyingError: EquatableError
    
    init(title: String? = nil, message: String? = nil, style: PreferredStyle = .alert, underlyingError: Error) {
        self.title = title
        self.message = message
        self.style = style
        self.underlyingError = underlyingError.toEquatableError()
    }
}

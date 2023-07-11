// 
//  Error+Equatable.swift
//  Mlem
//
//  Created by mormaer on 09/07/2023.
//  
//

import Foundation

extension Error where Self: Equatable {
    func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

extension Error {
    func toEquatableError() -> EquatableError {
        EquatableError(self)
    }
}

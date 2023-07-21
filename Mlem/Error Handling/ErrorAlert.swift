// 
//  ErrorAlert.swift
//  Mlem
//
//  Created by mormaer on 09/07/2023.
//  
//

import Foundation

struct ErrorAlert: Equatable {
    let title: String
    let message: String
}

extension ErrorAlert {
    static var unexpected: Self {
        .init(
            title: "Something went wrong",
            message: "Sorry, something unexpected happened. Please try again"
        )
    }
}

//
//  Access Token.swift
//  Mlem
//
//  Created by David Bureš on 06.05.2023.
//

import Foundation

class AccessTokenTracker: ObservableObject {
    @Published var token: String = ""
}

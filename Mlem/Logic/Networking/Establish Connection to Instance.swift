//
//  Establish Connection to Instance.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation

func establishConnectionToLemmyInstance(instanceURL: String) -> Void {
    let instanceAPIUrl: URL = URL(string: "wss://www.\(instanceURL)/api/v1/ws")!
    
}

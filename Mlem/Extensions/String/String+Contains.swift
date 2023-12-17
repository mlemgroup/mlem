//
//  String - Contains Elements From Array.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

extension String {
    func contains(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
}

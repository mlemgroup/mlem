//
//  APIComment+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIComment {
    var parentId: Int? {
        let components = path.components(separatedBy: ".")

        guard path != "0", components.count != 2 else {
            return nil
        }

        guard let id = components.dropLast(1).last else {
            return nil
        }

        return Int(id)
    }
}

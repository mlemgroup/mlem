//
//  InstanceModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 14/01/2024.
//

import Foundation

extension InstanceModel {
    func menuFunctions() -> [MenuFunction] {
        if let url {
            return [.shareMenuFunction(url: url)]
        }
        return []
    }
}

//
//  ApiGetPersonDetailsResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetPersonDetailsResponse: Person3ApiBacker {
    public var person2ApiBacker: any Person2ApiBacker { personView }
}

//
//  ApiMyUserInfo+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

extension ApiMyUserInfo: Person3ApiBacker {
    public var site: ApiSite? { nil }
    
    public var person2ApiBacker: any Person2ApiBacker {
        localUserView
    }
}

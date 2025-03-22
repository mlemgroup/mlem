//
//  Content Type.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

public enum ContentType: Int, Codable {
    case post, comment, community, person, message, mention, reply, instance, registrationApplication
}

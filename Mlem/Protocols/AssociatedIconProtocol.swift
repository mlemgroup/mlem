//
//  AssociatedIconProtocol.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-24.
//

import Foundation

/**
 Protocol for things that have an associated icon. Don't have a particular use for it right now, but it seems like it could be handy down the line and it makes things nice and tidy for extension readability
 */
protocol AssociatedIcon {
    var iconName: String { get }
    var iconNameFill: String { get }
}

//
//  FancyTabBarSelection.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-18.
//

import Foundation

/**
 Protocol to remove some redundant parameters.
 
 If needed, this can be used to jank up a "tab x of y" accessibility label by adding an index Int to the protocol
 */
protocol FancyTabBarSelection: Hashable, Comparable {
    var labelText: String? { get }
    var index: Int { get }
}

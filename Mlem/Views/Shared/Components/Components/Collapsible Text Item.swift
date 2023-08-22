//
//  Collapsible Text Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-15.
//

import Foundation
import SwiftUI

/**
 A little bit of custom styling wrapped around a DisclosureGroup
 */
struct CollapsibleTextItem: View {
    let titleText: String
    let bodyText: String
    
    var body: some View {
        DisclosureGroup {
            Text(.init(bodyText))
        } label: {
            Text(.init(titleText))
                .fontWeight(.semibold)
                .padding(.vertical, 5)
        }
        .tint(.primary)
    }
}

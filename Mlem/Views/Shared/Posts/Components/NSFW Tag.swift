//
//  NSFW Tag.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import SwiftUI

struct NSFWTag: View {
    let compact: Bool
    
    init(compact: Bool = false) {
        self.compact = compact
    }

    var body: some View {
        Text("NSFW")
            .dynamicTypeSize(.small ... .accessibility2)
            .foregroundColor(.white)
            .padding(2)
            .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                .foregroundColor(.red))
            .font((compact ? Font.caption2 : Font.subheadline).weight(compact ? Font.Weight.heavy : Font.Weight.black))
    }
}

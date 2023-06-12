//
//  Stickied Tag.swift
//  Mlem
//
//  Created by David Bureš on 04.04.2022.
//

import SwiftUI

struct StickiedTag: View
{
    let compact: Bool
    
    var body: some View
    {
        HStack
        { // TODO: Make it align properly with the text
            if !compact { Text("Stickied") }
            Image(systemName: "bandage.fill")
        }
        .dynamicTypeSize(.xSmall)
        .foregroundColor(.mint)
    }
}

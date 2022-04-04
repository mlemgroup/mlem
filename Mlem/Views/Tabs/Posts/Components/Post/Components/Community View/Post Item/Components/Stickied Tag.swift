//
//  Stickied Tag.swift
//  Mlem
//
//  Created by David Bureš on 04.04.2022.
//

import SwiftUI

struct Stickied_Tag: View {
    var body: some View {
        
        Spacer()
        
        HStack { // TODO: Make it align properly with the text
            Text("Stickied")
            Image(systemName: "bandage.fill")
        }
        .dynamicTypeSize(.xSmall)
        .foregroundColor(.mint)
    }
}

struct Stickied_Tag_Previews: PreviewProvider {
    static var previews: some View {
        Stickied_Tag()
    }
}

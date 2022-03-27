//
//  Post Info.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Post_Info: View {
    let iconToTextSpacing: CGFloat = 2
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: iconToTextSpacing) { // Number of upvotes
                Image(systemName: "arrow.up")
                Text("20")
            }
            
            HStack(spacing: iconToTextSpacing) { // Number of comments
                Image(systemName: "bubble.left")
                Text("4")
            }
            
            HStack(spacing: iconToTextSpacing) { // Time since posted
                Image(systemName: "clock")
                Text("3h")
            }
            
            Text("iMissElca")
        }
        .foregroundColor(.secondary)
        .dynamicTypeSize(.small)
    }
}

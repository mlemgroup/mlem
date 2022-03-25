//
//  Comment View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Comment_Item: View {
    @State var commentName: String
    
    var body: some View {
        Text(commentName)
        Image(systemName: "gear")
    }
}

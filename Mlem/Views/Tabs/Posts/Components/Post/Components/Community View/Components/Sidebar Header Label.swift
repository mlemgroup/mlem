//
//  Sidebar Header Label.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI

struct CommunitySidebarHeaderLabel : View {
    @State var text: String
    
    init(_ text: String) {
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        Text(text)
            .padding(3)
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 5).foregroundColor(.gray))
            .font(.footnote)
            .lineLimit(1)
    }
}

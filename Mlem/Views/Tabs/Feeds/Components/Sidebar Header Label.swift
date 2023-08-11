//
//  Sidebar Header Label.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import SwiftUI

struct CommunitySidebarHeaderLabel: View {
    @State var text: String
    
    init(_ text: String) {
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 6)
            .foregroundColor(.white)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
            .font(.callout)
            .lineLimit(1)
    }
}

struct CommunitySidebarHeaderLabel_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            CommunitySidebarHeaderLabel("This is a label")
        }
    }
}

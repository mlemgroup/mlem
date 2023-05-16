//
//  Community Search View.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CommunitySearchView: View
{
    
    @State var searchResults: [Community]?
    
    @State private var isShowingDarkBackground: Bool = false
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            Text("Ahoj")
        }
        .background(.background)
    }
}

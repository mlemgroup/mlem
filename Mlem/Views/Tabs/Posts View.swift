//
//  Posts View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Posts_View: View {
    let mockPostNames: [String] = ["Test", "Ahoj", "Tohle jsem já", "Nevím", "Tohle je extrémně dlouhý titulek. Jenom mě zajímá, jak to bude vypadat, když tam hodím něco takhle dlouhého"]
    let mockCommunity: String = "Cool Lions"
    
    var body: some View {
        let communityName: String = mockCommunity
        
        ScrollView {
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
    }
}

struct Posts_View_Previews: PreviewProvider {
    static var previews: some View {
        Posts_View()
    }
}

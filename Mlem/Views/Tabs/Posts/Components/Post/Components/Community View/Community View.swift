//
//  Community View.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import SwiftUI

struct Community_View: View {
    let mockPostNames: [String] = ["Test", "Ahoj", "Tohle jsem já", "Nevím", "Tohle je extrémně dlouhý titulek. Jenom mě zajímá, jak to bude vypadat, když tam hodím něco takhle dlouhého"]
    let mockCommunity: String = "Cool Lions"
    
    var body: some View {
        let communityName: String = mockCommunity
        ScrollView {
            /*Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)*/
        }
        .background(Color.secondarySystemBackground)
        .navigationTitle(communityName)
    }
}

struct Community_View_Previews: PreviewProvider {
    static var previews: some View {
        Community_View()
    }
}

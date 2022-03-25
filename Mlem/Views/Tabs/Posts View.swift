//
//  Posts View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Posts_View: View {
    let mockPostNames: [String] = ["Test", "Ahoj", "Tohle jsem já", "Nevím"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
            Post_Item(postName: mockPostNames.randomElement()!)
        }
    }
}

struct Posts_View_Previews: PreviewProvider {
    static var previews: some View {
        Posts_View()
    }
}

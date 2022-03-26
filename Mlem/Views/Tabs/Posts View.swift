//
//  Posts View.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Posts_View: View {
    let mockPostNames: [String] = ["Test", "Ahoj", "Tohle jsem já", "Nevím"]
    let mockInstance: String = "Lemmygrad"
    
    var body: some View {
        let instanceName: String = mockInstance
        
        NavigationView {
            List(0..<20) { item in
                Post_Item(postName: mockPostNames.randomElement()!)
            }
            .navigationTitle(instanceName)
        }
    }
}

struct Posts_View_Previews: PreviewProvider {
    static var previews: some View {
        Posts_View()
    }
}

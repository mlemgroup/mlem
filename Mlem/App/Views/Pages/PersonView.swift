//
//  PersonView.swift
//  Mlem
//
//  Created by Sjmarf on 30/05/2024.
//

import MlemMiddleware
import SwiftUI

struct PersonView: View {
    @State var person: any PersonStubProviding
    
    var body: some View {
        Text(person.name)
    }
}

//
//  MessageComposerView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation
import SwiftUI

struct MessageComposerView: View {
    
    let recipient: APIPerson
    
    var body: some View {
        Text("howdy\(recipient.name)")
    }
    
}

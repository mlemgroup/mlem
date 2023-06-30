//
//  Menu Button.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-30.
//

import SwiftUI

struct MenuButton: View {
    let label: String
    let imageName: String
    let callback: () -> Void
    
    var body: some View {
        Button {
            callback()
        } label: {
            HStack {
                Text(label)
                Image(systemName: imageName)
            }
        }
    }
}

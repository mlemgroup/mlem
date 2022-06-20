//
//  Error View.swift
//  Mlem
//
//  Created by David Bureš on 19.06.2022.
//

import SwiftUI

struct Error_View: View {
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "xmark.circle")
            Text(errorMessage)
        }
        .padding()
        .foregroundColor(.secondary)
    }
}

struct Error_View_Previews: PreviewProvider {
    static var previews: some View {
        Error_View(errorMessage: "Test error message")
    }
}

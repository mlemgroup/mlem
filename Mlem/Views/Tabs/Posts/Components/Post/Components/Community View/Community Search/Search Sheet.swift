//
//  Search Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

struct Search_Sheet: View {    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
            }
            Search_Field()
            
            Spacer()
        }
        .padding()
    }
}

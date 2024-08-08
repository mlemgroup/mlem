//
//  FormReadout.swift
//  Mlem
//
//  Created by Sjmarf on 08/08/2024.
//

import SwiftUI

struct FormReadout: View {
    @Environment(Palette.self) private var palette
    
    let label: LocalizedStringResource
    let value: Int
    
    init(_ label: LocalizedStringResource, value: Int) {
        self.label = label
        self.value = value
    }
    
    var body: some View {
        FormSection {
            VStack(spacing: AppConstants.halfSpacing) {
                Text(label)
                    .foregroundStyle(palette.secondary)
                Text(value.abbreviated)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tint)
            }
            .padding(.vertical, AppConstants.standardSpacing)
        }
    }
}

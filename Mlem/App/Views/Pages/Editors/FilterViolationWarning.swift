//
//  FilterViolationWarning.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-03.
//

import SwiftUI

struct FilterViolationWarning: View {
    @Environment(Palette.self) var palette

    let failures: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
            Label("Filter violation", systemImage: Icons.warning)
                .font(.footnote)
                .foregroundStyle(palette.warning)
                .padding(.vertical, 5)
                .padding(.horizontal, 7)
                .background {
                    Capsule()
                        .fill(palette.warning.opacity(0.2))
                        .stroke(palette.warning)
                }
            
            ForEach(failures.keys.sorted(), id: \.self) { instance in
                let failingText = Text(failures[instance] ?? "").fontWeight(.semibold)
                Text("\(instance) disallows \(failingText)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//
//  BanFormButtonStyle.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27.
//

import Foundation
import SwiftUI

struct BanFormButton: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.callout)
            .foregroundStyle(selected ? .white : .primary)
            .padding(.vertical, 4)
            .frame(maxWidth: 150)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(selected ? .blue : Color(uiColor: .systemGroupedBackground))
            }
    }
}

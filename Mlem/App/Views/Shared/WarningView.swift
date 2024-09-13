//
//  WarningView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation
import SwiftUI

struct WarningView: View {
    @Environment(Palette.self) var palette
    
    let iconName: String
    let text: String
    let inList: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(palette.warning)
                .frame(width: 50)
            Text(text)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .padding(inList ? 0 : Constants.main.doubleSpacing)
        .listRowBackground(listBackground())
        .background(background())
    }
    
    @ViewBuilder
    func listBackground() -> some View {
        if inList { backgroundRect }
    }
    
    @ViewBuilder
    func background() -> some View {
        if !inList { backgroundRect }
    }
    
    var backgroundRect: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(palette.warning, lineWidth: 3)
            .background(palette.warning.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//
//  WarningView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-14.
//

import Foundation
import SwiftUI

struct WarningView: View {
    let iconName: String
    let text: String
    let inList: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.red)
                .frame(width: 50)
            Text(text)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .padding(inList ? 0 : AppConstants.doubleSpacing)
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
            .stroke(.red, lineWidth: 3)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

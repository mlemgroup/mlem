//
//  WarningView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation
import Icons
import SwiftUI
import Theming

struct WarningView: View {
    let icon: Icon
    let text: String
    let inList: Bool
    let overrideColor: ThemedColor?
    
    init(icon: Icon, text: LocalizedStringResource, inList: Bool, overrideColor: ThemedColor? = nil) {
        self.icon = icon
        self.text = .init(localized: text)
        self.inList = inList
        self.overrideColor = overrideColor
    }
    
    @_disfavoredOverload
    init(icon: Icon, text: some StringProtocol, inList: Bool, overrideColor: ThemedColor? = nil) {
        self.icon = icon
        self.text = String(text)
        self.inList = inList
        self.overrideColor = overrideColor
    }
    
    var color: ThemedColor { overrideColor ?? .themedWarning }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(icon: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(color)
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
        RoundedRectangle(cornerRadius: 26)
            .stroke(color, lineWidth: 3)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

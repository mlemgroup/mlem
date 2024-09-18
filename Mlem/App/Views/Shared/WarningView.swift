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
    let overrideColor: Color?
    
    init(iconName: String, text: String, inList: Bool, overrideColor: Color? = nil) {
        self.iconName = iconName
        self.text = text
        self.inList = inList
        self.overrideColor = overrideColor
    }
    
    var color: Color { overrideColor ?? palette.warning }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(systemName: iconName)
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
        RoundedRectangle(cornerRadius: Constants.main.standardSpacing)
            .stroke(color, lineWidth: 3)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.standardSpacing))
    }
}

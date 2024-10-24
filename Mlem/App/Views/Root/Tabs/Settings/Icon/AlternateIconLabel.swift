//
//  AlternateIconCell.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI

struct AlternateIconLabel: View {
    let icon: AlternateIcon
    let selected: Bool

    var body: some View {
        VStack {
            getImage()
                .resizable()
                .scaledToFit()
                .frame(width: Constants.main.appIconSize, height: Constants.main.appIconSize)
                .foregroundColor(Color.white)
                .cornerRadius(Constants.main.appIconCornerRadius)
                .padding(3)
                .shadow(radius: 2, x: 0, y: 2)
                .overlay {
                    if selected {
                        ZStack {
                            RoundedRectangle(cornerRadius: Constants.main.appIconCornerRadius)
                                .stroke(Color(.secondarySystemBackground), lineWidth: 5)
                                .padding(2)
                            RoundedRectangle(cornerRadius: Constants.main.appIconCornerRadius + 2)
                                .stroke(.blue, lineWidth: 3)
                        }
                    }
                }
            Text(icon.name)
                .multilineTextAlignment(.center)
                .font(.footnote)
                .foregroundStyle(selected ? .blue : .secondary)
        }
    }
    
    func getImage() -> Image {
        let iconId: String
        if let id = icon.id {
            iconId = "\(id).preview"
        } else {
            iconId = "logo"
        }
        return .init(uiImage: .init(named: iconId) ?? .init())
    }
}

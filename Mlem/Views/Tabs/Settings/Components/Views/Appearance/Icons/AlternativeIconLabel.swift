//
//  AlternativeIconCell.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI

struct AlternativeIconLabel: View {
    let icon: AlternativeIcon

    var body: some View {
        HStack {
            getImage()
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.appIconSize, height: AppConstants.appIconSize)
                .foregroundColor(Color.white)
                .cornerRadius(AppConstants.appIconCornerRadius)
                .overlay {
                    RoundedRectangle(cornerRadius: AppConstants.appIconCornerRadius)
                        .stroke(Color(.secondarySystemBackground), lineWidth: 1)
                }
            VStack(alignment: .leading) {
                Text(icon.name)
                if let author = icon.author {
                    Text(author)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if icon.selected {
                Image(systemName: Icons.success)
            }
        }
    }
    
    func getImage() -> Image {
        let image = {
            guard let id = icon.id else {
                return Bundle.main.iconFileName
                    .flatMap { UIImage(named: $0) }
                    .map {
                        Image(uiImage: $0)
                    } ?? Image(systemName: Icons.noFile)
            }
            return Image(uiImage: UIImage(named: id) ?? UIImage(imageLiteralResourceName: id))
        }
  
        return image()
    }
}

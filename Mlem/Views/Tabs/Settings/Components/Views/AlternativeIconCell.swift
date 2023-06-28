//
//  AlternativeIconCell.swift
//  Mlem
//
//  Created by tht7 on 28/06/2023.
//

import SwiftUI

struct AlternativeIconCell: View {
    let icon: AlternativeIcon
    let setAppIcon: (_ id: String?) async -> Void

    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await setAppIcon(icon.id)
            }
        } label: {
            HStack {
                getImage()
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
                    Image(systemName: "checkmark")
                }
            }
        }.accessibilityElement(children: .combine)
    }

    func getImage() -> some View {
        let image = {
            guard let id = icon.id else {
                return Bundle.main.iconFileName
                    .flatMap { UIImage(named: $0) }
                    .map {
                        Image(uiImage: $0)
                    }!

            }
            return Image(uiImage: UIImage(named: id) ?? UIImage(imageLiteralResourceName: id))
        }
        return image()
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(Color.white)
            .cornerRadius(10.0)
    }
}

struct AlternativeIconCellPreview: PreviewProvider {
    static var previews: some View {
        AlternativeIconCell(icon: AlternativeIcon(id: nil, name: "Default", author: "Mlem team", selected: true)) { _ in }
    }
}

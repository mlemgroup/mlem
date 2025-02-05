//
//  ShieldsBadgeView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-28.
//

import SwiftUI

// https://shields.io/badges

struct ShieldsBadgeView: View {
    @Environment(Palette.self) var palette
    @Environment(\.openURL) var openURL
    
    var label: String
    var message: String?
    var link: URL?
    
    var logo: LogoType?
    
    init(shieldsUrl: URL, link: URL?) {
        self.link = link
        
        self.label = .init(localized: "Unsupported Badge")
        if let host = shieldsUrl.host(), host == "img.shields.io" {
            let path = shieldsUrl.pathComponents
            if path.count >= 3 {
                decodeBadgeType(path)
                decodeLabel(path[2])
                if let components = URLComponents(url: shieldsUrl, resolvingAgainstBaseURL: false) {
                    if let parameters = components.queryItems {
                        for parameter in parameters {
                            switch parameter.name {
                            case "logo":
                                if let value = parameter.value {
                                    decodeLogo(name: value)
                                }
                            case "label":
                                if let value = parameter.value {
                                    self.label = value
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    init(label: String, message: String?, link: URL?) {
        self.label = label
        self.message = message
        self.link = link
    }
    
    var body: some View {
        HStack(spacing: 7) {
            Group {
                switch logo {
                case let .bundle(name):
                    Image(name)
                case let .system(systemName):
                    Image(systemName: systemName)
                case nil:
                    EmptyView()
                }
                Text(label)
                    .padding(.vertical, 3)
            }
            .foregroundStyle(message != nil ? palette.primary : (palette.selectedInteractionBarItem))
            if let message {
                Text(message)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 7)
                    .foregroundStyle(palette.selectedInteractionBarItem)
                    .background(palette.accent)
            }
        }
        .padding(.leading, 7)
        .padding(.trailing, message == nil ? 7 : 0)
        .background(message == nil ? palette.accent : .clear)
        .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                .stroke(palette.accent, lineWidth: 1)
        }
        .onTapGesture {
            if let link {
                openURL(link)
            }
        }
    }
}

//
//  MarkdownInlineRenderer.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation
import SwiftUI

extension UIFont {
    static var bodyPointSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
}

extension MarkdownInlineNode {
    func attributedString(
        attributedString: AttributedString = .init(),
        attributes: AttributeContainer = .init()
    ) -> AttributedString {
        var attributedString = attributedString
        if let string {
            return attributedString + .init(string, attributes: applyAttributes(attributes))
        } else {
            for child in inlineChildren {
                attributedString = child.attributedString(
                    attributedString: attributedString,
                    attributes: applyAttributes(attributes)
                )
            }
        }
        return attributedString
    }
    
    private func applyAttributes(_ attributes: AttributeContainer) -> AttributeContainer {
        var attributes = attributes
        switch self {
        case .emphasis:
            attributes.font = (attributes.font ?? .body).italic()
        case .strong:
            attributes.font = (attributes.font ?? .body).bold()
        case .code:
            attributes.font = .body.monospaced()
//        case .superscript:
//            let size = UIFont.bodyPointSize / 2
//            attributes
//            attributes.baselineOffset = UIFont.bodyPointSize / 3
//        case .subscript:
//            let size = UIFont.bodyPointSize / 2
//            attributes.font = .systemFont(ofSize: size)
        case .strikethrough:
            attributes.uiKit.strikethroughStyle = .single
        case let .link(destination: url, children: _):
            attributes.link = URL(string: url)
        default:
            break
        }
        return attributes
    }
}

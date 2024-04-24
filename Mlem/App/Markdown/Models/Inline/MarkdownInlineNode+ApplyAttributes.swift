//
//  MarkdownInlineRenderer.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Foundation
import Nuke
import UIKit

extension UIFont {
    static var bodyPointSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
}

extension MarkdownInlineNode {
    func applyAttributes(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        let font: UIFont = (attributes[.font] as? UIFont) ?? .preferredFont(forTextStyle: .body)
        var attributes = attributes
        switch self {
        case .emphasis:
            attributes[.font] = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitItalic)
                )!,
                size: font.pointSize
            )
        case .strong:
            attributes[.font] = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitBold)
                )!,
                size: font.pointSize
            )
        case .code:
            attributes[.font] = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
        case .superscript:
            let size = UIFont.bodyPointSize / 2
            attributes[.font] = font.withSize(size)
            attributes[.baselineOffset] = UIFont.bodyPointSize / 3
        case .subscript:
            let size = UIFont.bodyPointSize / 2
            attributes[.font] = font.withSize(size)
        case .strikethrough:
            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        case let .link(destination: url, children: _):
            attributes[.link] = URL(string: url)
        default:
            break
        }
        return attributes
    }
}

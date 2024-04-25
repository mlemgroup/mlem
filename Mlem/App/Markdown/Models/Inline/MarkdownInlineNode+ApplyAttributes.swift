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
    func applyAttributes(_ attributes: AttributeContainer) -> AttributeContainer {
        let font: UIFont = (attributes.uiKit.font) ?? .preferredFont(forTextStyle: .body)
        var attributes = attributes
        switch self {
        case .emphasis:
            attributes.uiKit.font = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitItalic)
                )!,
                size: font.pointSize
            )
        case .strong:
            attributes.uiKit.font = UIFont(
                descriptor: font.fontDescriptor.withSymbolicTraits(
                    font.fontDescriptor.symbolicTraits.union(.traitBold)
                )!,
                size: font.pointSize
            )
        case .code:
            attributes.uiKit.font = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
            attributes.uiKit.backgroundColor = UIColor.secondarySystemBackground
        case .superscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
            attributes.baselineOffset = UIFont.bodyPointSize / 3
        case .subscript:
            let size = UIFont.bodyPointSize / 2
            attributes.uiKit.font = font.withSize(size)
        case .strikethrough:
            attributes.strikethroughStyle = .single
        case let .link(destination: url, children: _):
            attributes.link = URL(string: url)
        default:
            break
        }
        return attributes
    }
}

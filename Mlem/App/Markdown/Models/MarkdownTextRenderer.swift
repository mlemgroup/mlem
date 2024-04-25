//
//  MarkdownTextRenderer.swift
//  Mlem
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import Nuke
import SwiftUI

@Observable
class MarkdownTextRenderer {
    enum InlineType {
        case text(components: [Component], attatchments: [MarkdownAttatchment])
        case singleImage(attatchment: MarkdownAttatchment)
    }

    enum Component {
        case text(AttributedString)
        case image(MarkdownAttatchment)
    }
    
    var type: InlineType!
    
    private var components: [Component] = .init()
    private var attatchments: [MarkdownAttatchment] = .init()
    private var currentText: AttributedString = .init()
    
    init(inlines: [MarkdownInlineNode]) {
        renderInlines(inlines: inlines)
        components.append(.text(currentText))
        if attatchments.count == 1, let attachment = attatchments.first {
            var isSingleImage = true
            loop: for component in components {
                switch component {
                case let .text(attributedString):
                    if !attributedString.characters.allSatisfy(\.isWhitespace) {
                        isSingleImage = false
                        break loop
                    }
                default:
                    break
                }
            }
            if isSingleImage {
                self.type = .singleImage(attatchment: attachment)
                return
            }
        }
        self.type = .text(components: components, attatchments: attatchments)
    }
    
    private func renderInlines(
        inlines: [MarkdownInlineNode],
        attributes: AttributeContainer = .init()
    ) {
        for node in inlines {
            if let string = node.string {
                // swiftlint:disable:next shorthand_operator
                currentText = currentText + AttributedString(string, attributes: node.applyAttributes(attributes))
            } else {
                switch node {
                case let .image(source: source, children: _):
                    if let url = URL(string: source) {
                        components.append(.text(currentText))
                        currentText = .init()
                        let attatchment = MarkdownAttatchment(
                            url: url,
                            imageSize: attributes.uiKit.font?.pointSize ?? UIFont.bodyPointSize
                        )
                        attatchments.append(attatchment)
                        components.append(.image(attatchment))
                    }
                default:
                    renderInlines(
                        inlines: node.inlineChildren,
                        attributes: node.applyAttributes(attributes)
                    )
                }
            }
        }
    }
}

@Observable
class MarkdownAttatchment {
    var url: URL
    var imageSize: CGFloat
    
    var image: Image?
    
    init(url: URL, imageSize: CGFloat) {
        self.url = url
        self.imageSize = imageSize
    }
    
    func load(resize: Bool) async throws {
        guard image == nil else { return }
        let imageTask = ImagePipeline.shared.imageTask(with: url)
        guard let image: UIImage = try? await imageTask.image else { return }
        if !resize {
            DispatchQueue.main.async {
                self.image = Image(uiImage: image)
            }
            return
        }
        let height = imageSize
        let width = image.size.width * (height / image.size.height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        if let newImage {
            DispatchQueue.main.async {
                self.image = Image(uiImage: newImage)
            }
        }
    }
}

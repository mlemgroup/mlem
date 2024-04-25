//
//  MarkdownText.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import Nuke
import SwiftUI

struct MarkdownTextView: View {
    private var renderer: MarkdownTextRenderer
    
    init(_ inlines: [MarkdownInlineNode]) {
        self.renderer = .init()
        renderer.render(inlines: inlines)
    }
    
    private func text() -> some View {
        var text = Text("")
        for component in renderer.components {
            switch component {
            case let .text(attributedString):
                // swiftlint:disable:next shorthand_operator
                text = text + Text(attributedString)
            case let .image(attatchment):

                let image: Image = attatchment.image ?? Image(systemName: "arrow.down.circle")
                // swiftlint:disable:next shorthand_operator
                text = text + Text(image)
            }
        }
        return text
    }
    
    var body: some View {
        text()
            .task {
                for attatchment in renderer.attatchments {
                    try? await attatchment.load(resize: true)
                }
            }
    }
}

@Observable
private class MarkdownTextRenderer {
    enum Component {
        case text(AttributedString)
        case image(MarkdownAttatchment)
    }
    
    var components: [Component] = .init()
    var attatchments: [MarkdownAttatchment] = .init()
    private var currentText: AttributedString = .init()
    
    func render(inlines: [MarkdownInlineNode]) {
        renderInlines(inlines: inlines)
        components.append(.text(currentText))
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
private class MarkdownAttatchment {
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

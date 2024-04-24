//
//  MarkdownText.swift
//  Mlem
//
//  Created by Sjmarf on 23/04/2024.
//

import SwiftUI

struct MarkdownTextView: View {
    var inlines: [MarkdownInlineNode]
    
    init(_ string: String) {
        let blocks = UnsafeMarkdownNode.parseMarkdown(markdown: string) ?? []
        self.init(blocks.first?.children as? [MarkdownInlineNode] ?? [])
    }
    
    init(_ inlines: [MarkdownInlineNode]) {
        self.inlines = inlines
    }
    
    var body: some View {
        AttrText(inlines: inlines)
    }
}

private struct MarkdownInlineImage {
    let attatchment: NSTextAttachment
    let url: URL
}

struct AttrText: UIViewRepresentable {
    var attributedString: NSMutableAttributedString = .init()
    private var attatchments: [MarkdownInlineImage] = []
    var loadedImages: Bool = false
    
    init(inlines: [MarkdownInlineNode]) {
        render(inlines: inlines)
    }
    
    func render(inlines: [MarkdownInlineNode], attributes: [NSAttributedString.Key: Any] = .init()) {
        for node in inlines {
            if let string = node.string {
                attributedString.append(.init(string: string, attributes: node.applyAttributes(attributes)))
            } else {
                switch node {
                case let .image(source: source, children: _):
//                    if let url = URL(string: source) {
//                        let attachment = NSTextAttachment(image: .init(color: .red, size: .init(width: 100, height: 100))!)
//                        // attatchments.append(.init(attatchment: attachment, url: url))
//                        let newString = NSAttributedString(attachment: attachment)
//                        self.attributedString += AttributedString(newString)
//                    }
                    break
                default:
                    render(inlines: node.inlineChildren, attributes: node.applyAttributes(attributes))
                }
            }
        }
    }
    
//    func loadImages() async throws {
//        for attatchment in attatchments {
//            let imageTask = ImagePipeline.shared.imageTask(with: attatchment.url)
//            for await progress in imageTask.progress {
//                print(progress)
//            }
//            attatchment.attatchment.image = try await imageTask.image
//            loadedImages = true
//        }
//    }
    
    func makeUIView(context: Context) -> UILabel {
        UILabel()
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.lineBreakMode = .byWordWrapping
        uiView.numberOfLines = 0
        uiView.attributedText = attributedString
    }
}

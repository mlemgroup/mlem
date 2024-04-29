//
//  Markdown.swift
//  Mlem
//
//  Created by Sjmarf on 25/04/2024.
//

import LemmyMarkdownUI
import Nuke
import SwiftUI

struct Markdown: View {
    let markdown: String
    
    init(_ markdown: String) {
        self.markdown = markdown
    }
    
    var body: some View {
        LemmyMarkdownUI.Markdown(
            markdown,
            configuration: configuration
        )
    }
    
    var configuration: MarkdownConfiguration {
        .init(inlineImageLoader: loadInlineImage, imageBlockView: imageBlockView)
    }
    
    @ViewBuilder
    func imageBlockView(_ image: InlineImage) -> AnyView {
        AnyView(
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        )
    }
    
    func loadInlineImage(inlineImage: InlineImage) async {
        guard inlineImage.image == nil else { return }
        let imageTask = ImagePipeline.shared.imageTask(with: inlineImage.url)
        guard let image: UIImage = try? await imageTask.image else { return }
        let height = inlineImage.fontSize
        let width = image.size.width * (height / image.size.height)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2.0)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        if let newImage {
            DispatchQueue.main.async {
                inlineImage.image = Image(uiImage: newImage)
            }
        }
    }
}

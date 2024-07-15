//
//  UIImage+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import UIKit

extension UIImage {
    var isPortrait: Bool { size.height > size.width }
    var isLandscape: Bool { size.width > size.height }
    var breadth: CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect { .init(origin: .zero, size: breadthSize) }
    var circleMasked: UIImage? {
        guard let cgImage = cgImage?
            .cropping(to: .init(
                origin: .init(
                    x: isLandscape ? ((size.width - size.height) / 2).rounded(.down) : 0,
                    y: isPortrait ? ((size.height - size.width) / 2).rounded(.down) : 0
                ),
                size: breadthSize
            )) else { return nil }
        let format = imageRendererFormat
        format.opaque = false
        return UIGraphicsImageRenderer(size: breadthSize, format: format).image { _ in
            UIBezierPath(ovalIn: breadthRect).addClip()
            UIImage(cgImage: cgImage, scale: format.scale, orientation: imageOrientation)
                .draw(in: .init(origin: .zero, size: breadthSize))
        }
    }
}

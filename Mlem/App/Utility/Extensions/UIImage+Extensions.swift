//
//  UIImage+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 15/07/2024.
//

import CoreGraphics
import UIKit

extension UIImage {
    var isPortrait: Bool { size.height > size.width }
    var isLandscape: Bool { size.width > size.height }
    var breadth: CGFloat { min(size.width, size.height) }
    var breadthSize: CGSize { .init(width: breadth, height: breadth) }
    var breadthRect: CGRect { .init(origin: .zero, size: breadthSize) }
    
    var circleMasked: UIImage {
        let diameter = min(size.width, size.height)
        let isLandscape = size.width > size.height

        let xOffset = isLandscape ? (size.width - diameter) / 2 : 0
        let yOffset = isLandscape ? 0 : (size.height - diameter) / 2

        let imageSize = CGSize(width: diameter, height: diameter)

        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let ovalPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: imageSize))
            ovalPath.addClip()
            draw(at: CGPoint(x: -xOffset, y: -yOffset))
        }
    }
    
    func circleBorder(color: UIColor, width: CGFloat) -> UIImage {
        let diameter = min(size.width, size.height)
        let isLandscape = size.width > size.height

        let xOffset = isLandscape ? (size.width - diameter) / 2 : 0
        let yOffset = isLandscape ? 0 : (size.height - diameter) / 2

        let imageSize = CGSize(width: diameter, height: diameter)

        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            let ovalPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: imageSize))
            ovalPath.addClip()
            draw(at: CGPoint(x: -xOffset, y: -yOffset))
           
            color.setStroke()
            ovalPath.lineWidth = width
            ovalPath.stroke()
        }
    }
}

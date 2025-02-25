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
    
    static let blank: UIImage = .init()
    
    func validSize(fallback: CGSize) -> CGSize {
        size == .zero ? fallback : size
    }
    
    func boundedAspectRatio(bounds: AspectRatioBounds) -> CGSize {
        // sanity check: bounds do not conflict
        assert(bounds.boundsAreSane, "bounds are not sane")
        
        guard size != .zero else { return bounds.defaultSize }
        
        switch bounds {
        case let .bounded(vertical, horizontal):
            let aspectRatio = size.aspectRatio
            if let vertical, aspectRatio > vertical.aspectRatio {
                // if vertically bounded and taller than vertical bounds, clip to vertical bounds
                return vertical
            }
            if let horizontal, aspectRatio < horizontal.aspectRatio {
                // if horizontally bounded and wider than horizontal bounds, clip to horizontal bounds
                return horizontal
            }
            return size
        case let .absolute(size):
            // absolute: just return size
            return size
        }
    }
    
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
    
    func resized(to newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}

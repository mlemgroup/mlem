//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-12.
//

import UIKit

public extension UIImage {
    convenience init?(icon: Icon) {
        self.init(systemName: icon.computeImageName())
    }
}

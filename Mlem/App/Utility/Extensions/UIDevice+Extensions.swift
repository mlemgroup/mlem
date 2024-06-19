//
//  UIDevice+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import UIKit

extension UIDevice {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

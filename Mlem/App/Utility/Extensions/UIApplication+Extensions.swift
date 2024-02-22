//
//  UIApplication+FirstKeyWindow.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import Foundation
import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .keyWindow
    }
}

extension UIApplication {
    var topMostViewController: UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController?.topMostViewController()
    }
}

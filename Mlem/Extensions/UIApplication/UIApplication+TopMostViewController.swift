//
//  UIApplication+TopMostViewController.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-12-16.
//

import Foundation
import UIKit

extension UIApplication {
    var topMostViewController: UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController?.topMostViewController()
    }
}

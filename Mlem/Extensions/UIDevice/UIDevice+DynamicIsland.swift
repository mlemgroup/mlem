//
//  UIDevice+DynamicIsland.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-18.
//  Taken from :https://stackoverflow.com/a/74283502

import UIKit

extension UIDevice {
    // Get this value after sceneDidBecomeActive
    var hasDynamicIsland: Bool {
        // 1. dynamicIsland only support iPhone
        guard userInterfaceIdiom == .phone else {
            return false
        }
               
        // 2. Get key window, working after sceneDidBecomeActive
        guard let window = (UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }) else {
            print("Error: Did not find key window")
            return false
        }
       
        // 3.It works properly when the device orientation is portrait
        return window.safeAreaInsets.top >= 51
    }
}

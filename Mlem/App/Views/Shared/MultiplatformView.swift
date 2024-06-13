//
//  MultiplatformView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-13.
//

import Foundation
import SwiftUI

struct MultiplatformView<Content: View>: View {
    let ios: () -> Content
    let ipad: () -> Content
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            ios()
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            ipad()
        } else {
            preconditionFailure("Unsupported platform!")
        }
    }
}

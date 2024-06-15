//
//  MultiplatformView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-13.
//

import Foundation
import SwiftUI

struct MultiplatformView<Content: View>: View {
    let phone: () -> Content
    let pad: () -> Content
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            phone()
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            pad()
        } else {
            preconditionFailure("Unsupported platform!")
        }
    }
}
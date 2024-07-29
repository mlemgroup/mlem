//
//  MultiplatformView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-13.
//

import Foundation
import SwiftUI

struct MultiplatformView<PhoneContent: View, PadContent: View>: View {
    let phone: PhoneContent?
    let pad: PadContent?
    
    init(@ViewBuilder phone: () -> PhoneContent, @ViewBuilder pad: () -> PadContent) {
        if UIDevice.isPad {
            self.phone = nil
            self.pad = pad()
        } else {
            self.phone = phone()
            self.pad = nil
        }
    }
    
    var body: some View {
        if let phone {
            phone
        } else if let pad {
            pad
        } else {
            Text(verbatim: "MultiplatformView: Unsupported platform")
        }
    }
}

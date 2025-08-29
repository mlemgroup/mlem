//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-12.
//

import SwiftUI

public extension Toggle where Label == SwiftUI.Label<Text, Image> {
    nonisolated init(_ title: LocalizedStringResource, icon: Icon, isOn: Binding<Bool>) {
        self.init(title.key, systemImage: icon.computeImageName(), isOn: isOn)
    }
    
    @_disfavoredOverload
    nonisolated init(_ title: some StringProtocol, icon: Icon, isOn: Binding<Bool>) {
        self.init(title, systemImage: icon.computeImageName(), isOn: isOn)
    }
}

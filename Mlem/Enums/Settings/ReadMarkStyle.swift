//
//  ReadMarkStyle.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-02.
//

import Foundation

enum ReadMarkStyle: String, SettingsOptions {
    case bar, check
    
    var label: String { self.rawValue.capitalized }
    
    var id: Self { self }
}

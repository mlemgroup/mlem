//
//  Post Display Options.swift
//  Mlem
//
//  Created by David Bureš on 03.06.2023.
//

import Foundation
import SwiftUI

enum PostDisplayOptions: String, Equatable, CaseIterable
{
    case fullDisplay = "Full"
    case compactDisplay = "Compact"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

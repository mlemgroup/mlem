//
//  Translation Shower.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

private struct TranslateText: EnvironmentKey {
    static let defaultValue = { (_: String) -> Void in  }
}

extension EnvironmentValues {
    var translateText: (String) -> Void {
        get { self[TranslateText.self] }
        set { self[TranslateText.self] = newValue }
      }
}

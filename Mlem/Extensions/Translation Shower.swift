//
//  Translation Shower.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI

private struct TranslationShower: EnvironmentKey {
    static let defaultValue = { (_: String) -> Void in  }
}

extension EnvironmentValues {
    var translateText: (String) -> Void {
        get { self[TranslationShower.self] }
        set { self[TranslationShower.self] = newValue }
      }
}

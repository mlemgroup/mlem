//
//  PaletteProvider+Dependency.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-08.
//

import Dependencies
import Foundation

extension PaletteProvider: DependencyKey {
    static let liveValue = PaletteProvider()
}

extension DependencyValues {
    var palette: PaletteProvider {
        get { self[PaletteProvider.self] }
        set { self[PaletteProvider.self] = newValue }
    }
}

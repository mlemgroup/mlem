//
//  EnvironmentReader.swift
//  Mlem
//
//  Created by Sjmarf on 2026-09-04.
//

import SwiftUI

public struct EnvironmentReader<Content: View>: View {
    @Environment(\.self) private var environment

    @ViewBuilder var content: (EnvironmentValues) -> Content

    public init(@ViewBuilder _ content: @escaping (EnvironmentValues) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(environment)
    }
}

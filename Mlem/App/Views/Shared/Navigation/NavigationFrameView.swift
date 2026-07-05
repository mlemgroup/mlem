//
//  NavigationFrameView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-03.
//

import SwiftUI

// This struct exists to restrict the scope of view updates when
// `frame.page` changes. This can happen when `NavigationLayer.replace`
// is called.

struct NavigationFrameView: View {
    let frame: NavigationFrame

    var body: some View {
        frame.page.view()
    }
}

//
//  View+ReselectAction.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-04.
//
import Foundation
import SwiftUI

struct ReselectConsumer: ViewModifier {
    @Environment(\.tabReselectionHashValue) private var tabReselectionHashValue

    let tab: TabSelection
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: tabReselectionHashValue) { newValue in
                if newValue == tab.hashValue {
                    action()
                }
            }
    }
}

extension View {
    func reselectAction(tab: TabSelection, action: @escaping () -> Void) -> some View {
        modifier(ReselectConsumer(tab: tab, action: action))
    }
}

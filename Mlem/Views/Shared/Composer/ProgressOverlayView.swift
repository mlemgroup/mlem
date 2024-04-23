//
//  ProgressOverlayView.swift
//  Mlem
//
//  Created by Sjmarf on 13/03/2024.
//

import Foundation
import SwiftUI

struct ProgressOverlayView: ViewModifier {
    @Binding var isPresented: Bool
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Submitting")
                    .edgesIgnoringSafeArea(.all)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    func progressOverlay(isPresented: Binding<Bool>) -> some View {
        modifier(ProgressOverlayView(isPresented: isPresented))
    }
}

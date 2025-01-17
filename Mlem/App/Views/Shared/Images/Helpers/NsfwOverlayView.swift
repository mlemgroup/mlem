//
//  NsfwOverlayView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-03.
//

import Foundation
import SwiftUI

struct NsfwOverlay: View {
    @Binding var blurred: Bool
        
    @MainActor
    func setBlurred(_ newValue: Bool) {
        withAnimation(newValue ? .easeIn(duration: 0.15) : .easeOut(duration: 0.12)) {
            blurred = newValue
        }
    }
    
    var body: some View {
        if blurred {
            VStack(spacing: 8) {
                Image(systemName: Icons.warning)
                    .font(.largeTitle)
                Text("NSFW")
                    .fontWeight(.black)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .onTapGesture {
                setBlurred(false)
            }
        } else {
            Button {
                setBlurred(true)
            } label: {
                Image(systemName: Icons.hide)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 3)
                    .background(.thinMaterial, in: .rect(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .padding(4)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

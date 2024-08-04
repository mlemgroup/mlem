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
    let shouldBlur: Bool
    
    var body: some View {
        if shouldBlur {
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
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
                blurred = false
            }
        } else {
            Button {
                blurred = true
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

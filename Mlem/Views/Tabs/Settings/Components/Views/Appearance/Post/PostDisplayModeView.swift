//
//  PostDisplayModeView.swift
//  Mlem
//
//  Created by Sam Marfleet on 15/07/2023.
//

import SwiftUI

struct PostDisplayModeView: View {
    @State var postSize: PostSize
    var imageName: String
    
    @Binding var selected: PostSize
    
    var body: some View {
        Button {
            withAnimation {
                selected = postSize
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .fontWeight(.ultraLight)
                        .symbolRenderingMode(.monochrome)
                        .scaledToFit()
                        .opacity(selected == postSize ? 1 : 0.7)
                     
                    Spacer()
                        .background(selected == postSize ? Color.blue: Color.secondary)
                        .blendMode(.sourceAtop)
                }
                .drawingGroup(opaque: false)
                Text(postSize.label)
                    .foregroundStyle(selected == postSize ? Color.systemBackground : .primary)
                    .font(.footnote)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(selected == postSize ? .blue : .clear)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(EmptyButtonStyle())
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.2), value: selected)
    }
}

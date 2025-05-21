//
//  SignUpRecommendSingleInstanceView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-19.
//

import SwiftUI

struct SignUpRecommendSingleInstanceView: View {
    var body: some View {
        ZStack {
            image
                .opacity(0.5)
            image
                .saturation(1)
                .brightness(0.5)
                .mask { text }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var image: some View {
        Image("background.earth")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 3)
            .ignoresSafeArea()
    }
    
    var text: some View {
        Text("Join 45000 other users on Lemmy.world")
            .foregroundStyle(.white)
            .compositingGroup()
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
    }
}

#Preview {
    SignUpRecommendSingleInstanceView()
}

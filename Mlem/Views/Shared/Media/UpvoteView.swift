//
//  UpvoteView.swift
//  Mlem
//
//  Created by tht7 on 01/09/2023.
//

import Foundation
import SwiftUI

struct UpvoteView: View {
    static let roundedRectangle: RoundedRectangle = .init(cornerRadius: 8, style: .continuous)
    
    @Environment(\.fullscreenDismiss) var dismiss
    @Namespace var animation
    
    let upvoteFuncion: () async -> Void
    let completedImage: Image?
    
    @State var missionCompleted: Bool = false
    var body: some View {
        Group {
            if missionCompleted, let image = completedImage {
                image
//                    .resizable()
                    .matchedGeometryEffect(id: "main", in: animation, properties: .size)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            dismiss()
                        }
                    }
            } else {
                ProgressView()
                    .matchedGeometryEffect(id: "main", in: animation, properties: .size)
            }
        }
            .font(.largeTitle)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(UpvoteView.roundedRectangle)
            .task {
                await upvoteFuncion()
                if completedImage != nil {
                    withAnimation {
                        missionCompleted = true
                    }
                } else {
                    dismiss()
                }
            }
    }
}

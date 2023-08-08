//
//  LayoutWidgetView.swift
//  Mlem
//
//  Created by Sjmarf on 02/08/2023.
//

import SwiftUI

struct LayoutWidgetView: View {
    
    var widget: PostLayoutWidget
    var isDragging: Bool = false
    
    var animation: Namespace.ID
    
    func icon(_ imageName: String) -> some View {
        Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            switch widget.type {
            case .upvote:
                icon("arrow.up")
            case .downvote:
                icon("arrow.down")
            case .save:
                icon("bookmark")
            case .reply:
                icon("arrowshape.turn.up.left")
            case .share:
                icon("square.and.arrow.up")
            case .upvoteCounter:
                icon("arrow.up")
                Text("9")
            case .downvoteCounter:
                icon("arrow.down")
                Text("2")
            case .scoreCounter:
                icon("arrow.up")
                Text("7")
                icon("arrow.down")
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 40)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .matchedGeometryEffect(id: "Widget\(widget.hashValue)", in: animation)
        .transition(.scale(scale: 1))
    }
}

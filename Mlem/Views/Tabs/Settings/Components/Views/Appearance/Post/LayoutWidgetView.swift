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
        HStack {
            switch widget.type {
            case .upvote:
                icon("arrow.up")
            case .downvote:
                icon("arrow.down")
            case .save:
                icon("bookmark")
            case .reply:
                icon("arrowshape.turn.up.left")
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        // .shadow(color: .black.opacity(0.05), radius: 3, x: 3, y: 3)
        .matchedGeometryEffect(id: "Widget\(widget.hashValue)", in: animation)
        .transition(.scale(scale: 1))
    }
}

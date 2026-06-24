//
//  PostInfoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-06-23.
//

import SwiftUI
import MlemMiddleware

struct PostInfoView: View {
    let post: Post
    
    var body: some View {
        VStack {
            CopyableValue(title: "Local ID", value: "\(post.id)")
            CopyableValue(title: "Actor ID", value: "\(post.actorId.url)")
        }
        .padding(.horizontal)
    }
}

private struct CopyableValue: View {
    let title: LocalizedStringResource
    let value: String
    
    var body: some View {
        Button {
            UIPasteboard.general.string = value
            ToastModel.main.add(.success("Copied"))
        } label: {
            HStack {
                Text(title).bold()
                Spacer()
                Text(verbatim: value)
            }
        }
        .contentShape(.rect)
        .buttonStyle(.plain)
    }
}

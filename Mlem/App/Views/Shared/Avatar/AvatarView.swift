//
//  AvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import MlemMiddleware
import Nuke
import NukeUI
import SwiftUI

struct AvatarView: View {
    let url: URL?
    let type: AvatarType
    var showLoadingPlaceholder: Bool
    
    @State var uiImage: UIImage
    @State var loading: Bool
    
    init(
        url: URL?,
        type: AvatarType,
        showLoadingPlaceholder: Bool = true
    ) {
        self.url = url
        self.type = type
        self.showLoadingPlaceholder = showLoadingPlaceholder
    
        self._uiImage = .init(wrappedValue: .init())
        self._loading = .init(wrappedValue: url != nil)
    }
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .clipShape(Circle())
            .background {
                if url != nil, loading {
                    ProgressView()
                } else if url == nil {
                    DefaultAvatarView(avatarType: type)
                }
            }
            .task {
                await loadImage()
            }
            .aspectRatio(1, contentMode: .fit)
    }
    
    func loadImage() async {
        guard let url else { return }
        
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            uiImage = try await imageTask.image
            loading = false
        } catch {
            print(error)
        }
    }
}

extension AvatarView {
    init<T: Profile1Providing>(
        _ model: T?,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            type: T.avatarType,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }

    init(
        _ model: any Profile1Providing,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model.avatar,
            type: Swift.type(of: model).avatarType,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }
    
    init(
        _ model: (any Profile1Providing)?,
        type: AvatarType,
        showLoadingPlaceholder: Bool = true
    ) {
        self.init(
            url: model?.avatar,
            type: type,
            showLoadingPlaceholder: showLoadingPlaceholder
        )
    }
}

//
//  ExportablePostEditorView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-10-10.
//

import SwiftUI
import MlemMiddleware
import Theming
import ComponentViews

struct ExportablePostEditorView: View {
    @Environment(NavigationLayer.self) var navigation
    
    let post: any Post1Providing
    @State var showCommunity: Bool = true
    @State var showCreator: Bool = true
    @State var showStats: Bool = true

    @State var dimensions: CGSize = .zero
    
    // TODO: images all need to be fetched ahead of time and passed directly into LargePostView
    
    var body: some View {
        ScrollView {
            exportablePost
                .overlay {
                    GeometryReader { geometry in
                        Color.clear.contentShape(.rect)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onChange(of: geometry.size, initial: true) {
                                dimensions = .init(width: geometry.size.width, height: geometry.size.height)
                            }
                    }
                }
                .padding(.bottom, 200)
        }
        .background(.themedGroupedBackground)
        .overlay(alignment: .bottom) {
            Group {
                if #available(iOS 26, *) {
                    controls
                        .glassEffect(.regular.interactive(), in: .capsule)
                } else {
                    controls
                        .background(.regularMaterial, in: .capsule)
                }
            }
            .padding(.horizontal, 50)
            .padding(Constants.main.standardSpacing)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButtonView(ios18Label: .cancel)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu("Details", systemImage: "slider.horizontal.3") {
                    Toggle("Community", isOn: $showCommunity)
                    Toggle("Creator", isOn: $showCreator)
                    Toggle("Stats", isOn: $showStats)
                }
                .menuActionDismissBehavior(.disabled)
            }
        }
    }
    
    @ViewBuilder
    var controls: some View {
        if let imageData = snapshot().pngData(), // let imageData = createImageFromView(exportablePost, dimensions: dimensions)?.pngData(),
           let fileUrl = createTempFile(data: imageData, fileName: "post.png") {
            HStack {
                Button {
                    Task {
                        do {
                            try await ImageSaver().writeImageToPhotoAlbum(imageData: imageData)
                        } catch {
                            handleError(error)
                        }
                    }
                } label: {
                    Label("Save", icon: .general.import)
                        .padding(Constants.main.standardSpacing)
                        .contentShape(.rect)
                }
                
                ShareLink(item: fileUrl) {
                    Label("Share", icon: .general.export)
                        .padding(Constants.main.standardSpacing)
                        .contentShape(.rect)
                }
            }
            .id(dimensions)
            .font(.title2)
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .padding(.horizontal, Constants.main.halfSpacing)
        } else {
            ErrorView(.init(title: "Failed to create image"))
        }
    }
    
    var exportablePost: some View {
        ExportablePostView(post: post, showCommunity: showCommunity, showCreator: showCreator, showStats: showStats)
            .allowsHitTesting(false)
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: exportablePost)
        let view = controller.view
        // let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .init(x: 0, y: 15), size: dimensions)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: dimensions)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    private func createTempFile(data: Data, fileName: String) -> URL? {
        do {
            return try data.writeToTempFile(fileName: fileName)
        } catch {
            handleError(error)
            return nil
        }
    }
}

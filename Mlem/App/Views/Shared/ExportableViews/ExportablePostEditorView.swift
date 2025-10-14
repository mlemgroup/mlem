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
import Nuke
import Media

struct ExportablePostEditorView: View {
    @Environment(NavigationLayer.self) var navigation
    
    let post: any Post1Providing
    @State var showCommunity: Bool = true
    @State var showCreator: Bool = true
    @State var showStats: Bool = true

    @State var dimensions: CGSize = .zero
    
    @State var staticImages: [URL: Image]?
    @State var failed: Bool = false
    
    @State var staticImageProvider: StaticImageProvider = .init()
  
    var body: some View {
        content
//        switch staticImageProvider.loadingState {
//        case .empty, .loading:
//            ProgressView()
//                .task {
//                    let imageRequests = await post.imageRequests(configuration: .forPostSize(.large))
//                    staticImageProvider.loadImages(for: imageRequests)
//                }
//        case .done:
//            content
//        case .failed:
//            Text("Something went wrong")
//        }
    }
    
    var content: some View {
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
        HStack {
            saveButton
            shareButton
        }
        .font(.title2)
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .padding(.horizontal, Constants.main.halfSpacing)
    }
    
    @ViewBuilder var saveButton: some View {
        if let imageData = snapshot?.pngData() {
            Button("Save", icon: .general.import) {
                Task {
                    do {
                        try await ImageSaver().writeImageToPhotoAlbum(imageData: imageData)
                    } catch {
                        handleError(error)
                    }
                }
            }
            .padding(Constants.main.standardSpacing)
            .contentShape(.rect)
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var shareButton: some View {
        if let imageData = snapshot?.pngData(),
        let fileUrl = createTempFile(data: imageData, fileName: "post.png") {
            ShareLink(item: fileUrl)
                .padding(Constants.main.standardSpacing)
                .contentShape(.rect)
        } else {
            ProgressView()
        }
    }
        
    var exportablePost: some View {
        ExportablePostView(post: post, showCommunity: showCommunity, showCreator: showCreator, showStats: showStats)
            .allowsHitTesting(false)
    }
    
    var snapshot: UIImage? {
        createImageFromView(exportablePost)
//        let renderer = ImageRenderer(content: exportablePost)
//        renderer.scale = 3
//        renderer.proposedSize.width = UIScreen.main.bounds.width
//        return renderer.uiImage
        
//        let imageView = ExportablePostView(post: post, showCommunity: showCommunity, showCreator: showCreator, showStats: showStats)
//            .environment(staticImageProvider)
//        
//        let controller = UIHostingController(rootView: imageView)
//        let view = controller.view
//        view?.bounds = CGRect(origin: .init(x: 0, y: 15), size: dimensions)
//        view?.backgroundColor = .clear
//
//        let renderer = UIGraphicsImageRenderer(size: dimensions)
//        return renderer.image { _ in
//            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
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

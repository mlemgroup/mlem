//
//  QuickLookView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-07.
//

import Foundation
import QuickLook
import SwiftUI
import UIKit.UINavigationController

struct QuickLookView: UIViewControllerRepresentable {

    let urls: [URL]
        
    func makeUIViewController(context: Context) -> QuickLookPreviewController {
        .init(urls: urls)
    }
    
    func makeCoordinator() -> QuickLookDataSource {
        .init(urls: urls)
    }
    
    func updateUIViewController(_ uiViewController: QuickLookPreviewController, context: Context) {
        // no-op.
    }
}

///
final class QuickLookPreviewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    let urls: [URL]
    
    init(urls: [URL]) {
        self.urls = urls
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var qlPreviewController: QLPreviewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if qlPreviewController == nil {
            let preview = QLPreviewController()
            preview.dataSource = self
            preview.delegate = self
            preview.currentPreviewItemIndex = 0
            present(preview, animated: true)
            qlPreviewController = preview
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        /// Set the parent `SwiftUI.PresentationHostingController` background colour to transparent, so we can see behind Quick Look when user interactively dismisses Quick Look.
        /// Other techniques call for using a separate "TransparentViewController" to achieve this effect, but it doesn't seem necessary(?) [2023.08]
        parent?.view?.backgroundColor = .clear
//        parent?.modalPresentationStyle = .overFullScreen
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        urls[index] as NSURL
    }
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        dismiss(animated: false)
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        dismiss(animated: false)
    }
}

final class QuickLookDataSource: QLPreviewControllerDataSource {
    
    let urls: [URL]
    
    init(urls: [URL]) {
        self.urls = urls
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        urls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        urls[index] as NSURL
    }
}

final class QuickLookPreview: ObservableObject {
    @Published var url: URL?
}

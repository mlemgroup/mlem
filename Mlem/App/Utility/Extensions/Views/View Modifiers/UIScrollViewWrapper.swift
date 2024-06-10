//
//  UIScrollViewWrapper.swift
//  lingq-5
//
//  Created by Timothy Costa on 2019/07/05.
//  Copyright © 2019 timothycosta.com. All rights reserved.
//

import SwiftUI

// struct QuickSwipeScrollDelegate: UIScrollViewCon {
//
// }

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewViewController {
        let vc = UIScrollViewViewController()
        vc.hostingController.rootView = AnyView(content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(content())
    }
}

class UIScrollViewViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        return view
    }()

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        pinEdges(of: scrollView, to: view)

        hostingController.willMove(toParent: self)
        scrollView.addSubview(hostingController.view)
        pinEdges(of: hostingController.view, to: scrollView)
        hostingController.didMove(toParent: self)
    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor)
        ])
    }
}

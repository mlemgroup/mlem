//
//  InAppWebView.swift
//  Mlem
//
//  Created by tht7 on 22/06/2023.
//

import Foundation
import SwiftUI
import WebKit

struct InAppWebView: UIViewRepresentable {
    // 1
    let url: URL


    // 2
    func makeUIView(context: Context) -> WKWebView {

        return WKWebView()
    }

    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        print("webview for \(url)")
        webView.load(request)
    }
}

//
//  In-App Safari.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import SwiftUI
import SafariServices

struct InAppSafari: UIViewControllerRepresentable {
    @State var urlToOpen: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false
        configuration.entersReaderIfAvailable = false
        
        return SFSafariViewController(url: urlToOpen, configuration: configuration)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

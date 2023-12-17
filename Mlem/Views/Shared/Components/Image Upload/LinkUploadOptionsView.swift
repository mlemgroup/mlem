//
//  LinkUploadOptionsView.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import SwiftUI

struct LinkUploadOptionsView<Content: View>: View {
    var proxy: LinkAttachmentProxy
    
    let label: Content
    
    init(proxy: LinkAttachmentProxy, @ViewBuilder label: () -> Content) {
        self.proxy = proxy
        self.label = label()
    }
    
    var body: some View {
        Menu {
            Button(action: proxy.attachImageAction) {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }
            Button(action: proxy.attachFileAction) {
                Label("Choose File", systemImage: "folder")
            }
            Button(action: proxy.pasteFromClipboardAction) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
        } label: {
            label
        }
    }
}

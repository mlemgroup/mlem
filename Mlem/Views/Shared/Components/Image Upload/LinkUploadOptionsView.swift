//
//  LinkUploadOptionsView.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import SwiftUI

struct LinkUploadOptionsView<Content: View>: View {
    @ObservedObject var model: LinkAttachmentModel
    
    let label: Content
    
    init(model: LinkAttachmentModel, @ViewBuilder label: () -> Content) {
        self.model = model
        self.label = label()
    }
    
    var body: some View {
        Menu {
            Button(action: model.attachImageAction) {
                Label("Photo Library", systemImage: "photo.on.rectangle")
            }
            Button(action: model.attachFileAction) {
                Label("Choose File", systemImage: "folder")
            }
            Button(action: model.pasteFromClipboardAction) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
        } label: {
            label
        }
    }
}

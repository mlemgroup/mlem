//
//  LinkAttachmentProxy.swift
//  Mlem
//
//  Created by Sjmarf on 17/12/2023.
//

import Foundation

struct LinkAttachmentProxy {
    private let model: LinkAttachmentModel
    
    var imageModel: PictrsImageModel? {
        return model.imageModel
    }

    func attachImageAction() {
        model.showingPhotosPicker = true
    }
    
    func attachFileAction() {
        model.showingFilePicker = true
    }
    
    func pasteFromClipboardAction() {
        model.pasteFromClipboard()
    }
    
    func removeLinkAction() {
        model.url = ""
    }
    
    init(model: LinkAttachmentModel) {
        self.model = model
    }
}

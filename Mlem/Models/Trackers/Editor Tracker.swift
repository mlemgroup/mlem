//
//  Editor Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//
import Foundation

class EditorTracker: ObservableObject {
    @Published var editResponse: ConcreteEditorModel?
    @Published var editPost: PostEditorModel?
    @Published var selectText: SelectTextModel?

    func openEditor(with editResponse: ConcreteEditorModel) {
        self.editResponse = editResponse
    }
    
    func openEditor(with editPost: PostEditorModel) {
        self.editPost = editPost
    }
    
    func openEditor(with selectText: SelectTextModel) {
        self.selectText = selectText
    }
}

struct SelectTextModel: Identifiable {
    var id: Int { text.hashValue }
    var text: String
}

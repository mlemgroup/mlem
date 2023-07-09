//
//  Documents View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-09.
//

import Foundation
import SwiftUI

struct DocumentsView: View {
    @State var presentedDocument: Document?
    
    var body: some View {
        List {
            Button {
                presentedDocument = privacyPolicy
            } label: {
                HStack {
                    Image(systemName: "binoculars.fill")
                        .foregroundColor(.purple)
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                }
            }
            
            Button {
                presentedDocument = eula
            } label: {
                HStack {
                    Image(systemName: "doc.plaintext.fill")
                        .foregroundColor(.purple)
                    Text("EULA")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(item: $presentedDocument) { presentedDocument in
            documentView(doc: presentedDocument)
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func documentView(doc: Document) -> some View {
        ScrollView {
            MarkdownView(text: doc.body, isNsfw: false)
        }
        .padding()
    }
    
}

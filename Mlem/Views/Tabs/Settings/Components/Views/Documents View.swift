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
                }
            }
            .buttonStyle(.plain)
            
            Button {
                presentedDocument = eula
            } label: {
                HStack {
                    Image(systemName: "doc.plaintext.fill")
                        .foregroundColor(.purple)
                    Text("EULA")
                }
            }
            .buttonStyle(.plain)
        }
        .sheet(item: $presentedDocument) { presentedDocument in
            documentView(doc: presentedDocument)
        }
    }
    
    func documentView(doc: Document) -> some View {
        ScrollView {
            MarkdownView(text: doc.body, isNsfw: false)
        }
        .padding()
    }
    
}

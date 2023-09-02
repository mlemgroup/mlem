//
//  HighlightedResultText.swift
//  Mlem
//
//  Created by Sjmarf on 26/08/2023.
//

import SwiftUI

struct SearchResultTextView: View {
    @State var components: EnumeratedSequence<[String]>?
    let text: String
    let highlight: String
    
    init(_ text: String, highlight: String) {
        self.text = text
        self.highlight = highlight.lowercased()
    }
    
    var body: some View {
        VStack {
            if let components = components {
                components.map { (index, segment) in
                    Text(segment)
                        .foregroundColor(index == 1 ? .primary : .secondary)
                }
                .reduce(Text("")) { $0 + $1 }
            }
        }
        .onAppear {
            let components = text.lowercased().components(separatedBy: highlight)
            
            if components.count == 1 {
                self.components = [text].enumerated()
                
            } else {
                var newComponents: [String] = .init()
                var startIndex = text.startIndex
                
                // Add the highlight text back in, preserving case
                for (componentIndex, component) in components.enumerated() {
                    var endIndex = text.index(startIndex, offsetBy: component.count)
                    newComponents.append(component)
                    startIndex = endIndex
                    
                    if componentIndex == 1 {
                        break
                    }
                    endIndex = text.index(startIndex, offsetBy: highlight.count)
                    newComponents.append(String(text[startIndex..<endIndex]))
                    startIndex = endIndex
                }
                newComponents.append(String(text[startIndex..<text.endIndex]))
                
                self.components = newComponents.enumerated()
            }
        }
    }
}

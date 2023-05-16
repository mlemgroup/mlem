//
//  Custom Search Bar.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import SwiftUI

struct CustomSearchField: UIViewRepresentable
{
    @Binding var text: String
    var placeholder: String
    
    class Delegate: NSObject, UISearchBarDelegate
    {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        
        searchBar.autocorrectionType = .no
        
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> CustomSearchField.Delegate {
        return Delegate(text: $text)
    }
}

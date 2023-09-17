//
//  LemmyURL.swift
//  Mlem
//
//  Created by mormaer on 15/09/2023.
//
//

import Foundation

struct LemmyURL {
    let url: URL
    
    init?(string: String?) {
        guard let string else {
            return nil
        }
        
        if let url = URL(string: string) {
            self.url = url
        } else if let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) {
            self.url = url
        } else {
            return nil
        }
    }
}

//
//  View+NavigationTransition.swift
//  Mlem
//
//  Created by Sjmarf on 29/08/2024.
//

import SwiftUI

extension View {
    func navigationTransition_(sourceID: any Hashable, in namespace: Namespace.ID?) -> some View {
        Group {
            if #available(iOS 18.0, *), let namespace {
                self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
            } else {
                self
            }
        }
    }
    
    func matchedTransitionSource_(id: some Hashable, in namespace: Namespace.ID) -> some View {
        Group {
            if #available(iOS 18.0, *) {
                self.matchedTransitionSource(id: id, in: namespace, configuration: { config in
                    config.clipShape(.rect(cornerRadius: 10))
                })
            } else {
                self
            }
        }
    }
}

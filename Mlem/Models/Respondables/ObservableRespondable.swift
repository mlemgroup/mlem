//
//  ObservableRespondable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation

class ObservableRespondable: ObservableObject {
    @Published var concreteRespondable: ConcreteRespondable?
    
    init() {
        concreteRespondable = nil
    }
    
    func updateWith(concreteRespondable: ConcreteRespondable) {
        self.concreteRespondable = concreteRespondable
    }
}

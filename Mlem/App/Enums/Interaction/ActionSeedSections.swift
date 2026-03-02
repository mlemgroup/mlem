//
//  ActionSeedSections.swift
//  Mlem
//
//  Created by Sjmarf on 2026-02-28.
//

import Actions

struct ActionSeedSections {
    let sections: [[ActionSeed]]

    init(sections: [[ActionSeed]]) {
        self.sections = sections
    }

    var all: [ActionSeed] { sections.reduce([], +) }
}

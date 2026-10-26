//
//  VotesModel+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-17.
//

import Icons
import MlemMiddleware
import Theming

extension VotesModel {
    var icon: Icon { myVote.icon }
    var color: ThemedColor { myVote.color }
}

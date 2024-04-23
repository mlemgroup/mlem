//
//  PostFeedView+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import Foundation

extension PostFeedView {
    func genOuterSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableOuterTypes.map { type in
            let isSelected = postSortType == type
            let imageName = isSelected ? type.iconNameFill : type.iconName
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: imageName,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
    
    func genTopSortMenuFunctions() -> [MenuFunction] {
        PostSortType.availableTopTypes.map { type in
            let isSelected = postSortType == type
            return MenuFunction.standardMenuFunction(
                text: type.label,
                imageName: isSelected ? Icons.timeSortFill : Icons.timeSort,
                enabled: !isSelected
            ) {
                postSortType = type
            }
        }
    }
}

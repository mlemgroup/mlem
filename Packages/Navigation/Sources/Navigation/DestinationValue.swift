//
//  DestinationValue.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-26.
//

import Foundation

/// Essentially a cheap "view-model", wrap `DestinationValue` inside a `Routable` value, then use that value as the data to define navigation destinations.
///
/// Conforming types can be used to drive value-based navigation for destinations that are defined semantically or are not (yet) mapped to a particular data-type or view model.
///
/// For example: 
/// - Many `Settings` views are presented based on their purpose and not the data they present.
/// - In this scenario, we can define a set of semantically named enum cases (i.e. `.general` or `.about`), and treat these enum cases as values that drive navigation.
/// - See `AppRoute` settings routes for an example implementation.
///
/// - Warning: Avoid directly adding `DestinationValue` to a navigation path or using them as data to define `navigationDestination(...)`.
public protocol DestinationValue: Hashable {}

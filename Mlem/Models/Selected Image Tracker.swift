//
//  Selected Image.swift
//  Mlem
//
//  Created by David Bureš on 11.05.2023.
//

import Foundation
import SwiftUI

class SelectedImageTracker: ObservableObject
{
    @Published var image: Image = Image(systemName: "plus")
    @Published var isShowingImage: Bool = false
}

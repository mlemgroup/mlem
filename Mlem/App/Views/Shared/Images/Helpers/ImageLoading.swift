//
//  ImageLoading.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-22.
//

import Foundation
import UIKit

protocol ImageLoading {
    var url: URL? { get }
    var loading: ImageLoadingState { get }
    var error: ImageLoadingError? { get }
    var uiImage: UIImage? { get }
    func load() async
    func bypassProxy() async
}

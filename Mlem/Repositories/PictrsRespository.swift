//
//  PictrsRespository.swift
//  Mlem
//
//  Created by Sjmarf on 29/09/2023.
//

import Dependencies
import PhotosUI
import SwiftUI

class PictrsRespository {
    @Dependency(\.apiClient) var apiClient
    
    func uploadImage(
        imageModel: PictrsImageModel,
        imageSelection: PhotosPickerItem,
        onUpdate updateCallback: @escaping (_ imageModel: PictrsImageModel) -> Void
    ) async throws -> URLSessionUploadTask? {
        var imageModel = imageModel
        do {
            let data = try await imageSelection.loadTransferable(type: Data.self)
            
            if let data = data {
                if let uiImage = UIImage(data: data) {
                    imageModel.image = Image(uiImage: uiImage)
                }
                return try await apiClient.uploadImage(data, onProgress: {
                    print("Uploading: \(round($0*100))%")
                    imageModel.state = .uploading(progress: $0)
                    updateCallback(imageModel)
                }, onCompletion: { response in
                    if let response = response {
                        if let firstFile = response.files?.first {
                            imageModel.state = .uploaded(file: firstFile)
                            updateCallback(imageModel)
                        } else {
                            print("Upload failed: \(response.msg)")
                            imageModel.state = .failed(response.msg)
                            updateCallback(imageModel)
                        }
                    } else {
                        print("Upload failed: Response is nil")
                        imageModel.state = .failed(nil)
                        updateCallback(imageModel)
                    }
                })
            }
        } catch {
            print("Upload failed: \(error)")
            imageModel.state = .failed(nil)
            updateCallback(imageModel)
        }
        return nil
    }
}

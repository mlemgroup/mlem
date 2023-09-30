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
    ) async throws -> Task<(), any Error>? {
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
                }, catch: { error in
                    print("Upload failed: \(error)")
                    switch error {
                    case APIClientError.decoding(let data):
                        imageModel.state = .failed(String(data: data, encoding: .utf8))
                    default:
                        imageModel.state = .failed(String(describing: error))
                    }
                    
                    updateCallback(imageModel)
                })
            } else {
                imageModel.state = .failed("No data to upload")
                updateCallback(imageModel)
            }
        } catch {
            print("Upload failed: \(error)")
            imageModel.state = .failed(String(describing: error))
            updateCallback(imageModel)
        }
        return nil
    }
    
    func deleteImage(file: PictrsFile) async throws {
        // A decoding error will always be throws because the delete request has no response... there's
        // certainly a better way to handle this by making ImageDeleteRequest itself have no response
        // object, possibly via an intermediate APIRequestWithResponse protocol
        do {
            try await apiClient.deleteImage(file: file)
        } catch APIClientError.decoding(_) { }
    }
}

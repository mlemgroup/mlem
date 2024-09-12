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
        onUpdate updateCallback: @escaping (_ imageModel: PictrsImageModel) -> Void
    ) async throws -> Task<Void, any Error>? {
        var imageModel = imageModel
        guard case let .readyToUpload(data: data) = imageModel.state else {
            imageModel.state = .failed("No data")
            updateCallback(imageModel)
            return nil
        }
        do {
            return try await apiClient.uploadImage(data, onProgress: {
                print("Uploading: \(round($0 * 100))%")
                imageModel.state = .uploading(progress: $0)
                updateCallback(imageModel)
            }, onCompletion: { response in
                if let response {
                    if let firstFile = response.files?.first {
                        imageModel.state = .uploaded(file: firstFile)
                        updateCallback(imageModel)
                    } else {
                        print("Upload failed (1): \(String(describing: response.msg))")
                        imageModel.state = .failed(response.msg)
                        updateCallback(imageModel)
                    }
                } else {
                    print("Upload failed: Response is nil")
                    imageModel.state = .failed(nil)
                    updateCallback(imageModel)
                }
            }, catch: { error in
                print("Upload failed (2): \(error)")
                switch error {
                case let APIClientError.decoding(data, _):
                    if let text = String(data: data, encoding: .utf8) {
                        if text.contains("413 Request Entity Too Large") {
                            imageModel.state = .failed("Image too large")
                        } else {
                            imageModel.state = .failed(text)
                        }
                    } else {
                        imageModel.state = .failed("Could not decode error")
                    }
                default:
                    imageModel.state = .failed(error.localizedDescription)
                }
                
                updateCallback(imageModel)
            })
        } catch {
            print("Upload failed (3): \(error)")
            imageModel.state = .failed(error.localizedDescription)
            updateCallback(imageModel)
        }
        return nil
    }
    
    func deleteImage(file: PictrsFile) async throws {
        // A decoding error will always be throws because the delete request has no response... there's
        // certainly a better way to handle this by making ImageDeleteRequest itself have no response
        // associated with it, possibly via an intermediate APIRequestWithResponse protocol
        do {
            try await apiClient.deleteImage(file: file)
        } catch APIClientError.decoding(_, _) {}
    }
}

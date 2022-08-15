//
//  PhotoGalleryService.swift
//  CameraApp
//
//  Created by Serhii Palash on 14/08/2022.
//

import Photos

final class PhotoGalleryService: NSObject, ObservableObject {
    var smartAlbumType: PHAssetCollectionSubtype

    private var assetCollection: PHAssetCollection?

    init(smartAlbum smartAlbumType: PHAssetCollectionSubtype) {
        self.smartAlbumType = smartAlbumType
        super.init()

        load()
    }

    func load() {
        guard let assetCollection = Self.getSmartAlbum(subtype: smartAlbumType) else { return }
        self.assetCollection = assetCollection
    }

    func addImage(_ imageData: Data) async  {
        guard let assetCollection = self.assetCollection else { return }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                if let assetPlaceholder = creationRequest.placeholderForCreatedAsset {
                    creationRequest.addResource(with: .photo, data: imageData, options: nil)

                    if
                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection),
                        assetCollection.canPerform(.addContent)
                    {
                        let fastEnumeration = NSArray(array: [assetPlaceholder])
                        albumChangeRequest.addAssets(fastEnumeration)
                    }
                }
            }
        } catch let error {
            print("Error adding image to photo library: \(error.localizedDescription)")
        }
    }

    private static func getSmartAlbum(subtype: PHAssetCollectionSubtype) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: fetchOptions)
        return collections.firstObject
    }
}

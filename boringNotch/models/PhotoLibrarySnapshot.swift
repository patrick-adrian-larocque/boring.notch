// SPDX-License-Identifier: GPL-3.0-only

import Foundation

/// Read-only presentation data. Album membership does not duplicate the asset.
/// Symbol artwork is deliberately limited to this sample-data prototype.
struct PhotoBrowserItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let symbolName: String
}

struct PhotoBrowserAlbum: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let photoIDs: [String]
}

struct PhotoLibrarySnapshot: Equatable, Sendable {
    let photos: [PhotoBrowserItem]
    let albums: [PhotoBrowserAlbum]

    /// Preserve library order, ignore missing references, and show each asset
    /// once even if album membership contains repeated identifiers.
    func photos(in albumID: String?) -> [PhotoBrowserItem] {
        guard let albumID else { return photos }
        guard let album = albums.first(where: { $0.id == albumID }) else { return [] }
        let membership = Set(album.photoIDs)
        return photos.filter { membership.contains($0.id) }
    }

    static let sample = PhotoLibrarySnapshot(
        photos: [
            PhotoBrowserItem(id: "mountains", title: "Mountain walk", symbolName: "mountain.2.fill"),
            PhotoBrowserItem(id: "lake", title: "By the lake", symbolName: "water.waves"),
            PhotoBrowserItem(id: "city", title: "City afternoon", symbolName: "building.2.fill"),
            PhotoBrowserItem(id: "garden", title: "Garden", symbolName: "leaf.fill"),
            PhotoBrowserItem(id: "sunset", title: "Evening sky", symbolName: "sun.horizon.fill"),
            PhotoBrowserItem(id: "coffee", title: "Coffee break", symbolName: "cup.and.saucer.fill")
        ],
        albums: [
            PhotoBrowserAlbum(id: "outdoors", title: "Outdoors", photoIDs: ["mountains", "lake", "garden", "sunset"]),
            PhotoBrowserAlbum(id: "everyday", title: "Everyday", photoIDs: ["city", "garden", "coffee"]),
            PhotoBrowserAlbum(id: "to-organize", title: "To organize", photoIDs: [])
        ]
    )
}

struct PhotoBrowserSelection: Equatable {
    private(set) var albumID: String?
    private(set) var photoID: String?

    mutating func selectAlbum(_ id: String?, in library: PhotoLibrarySnapshot) {
        guard id == nil || library.albums.contains(where: { $0.id == id }) else { return }
        albumID = id
        photoID = nil
    }

    mutating func selectPhoto(_ id: String?, in library: PhotoLibrarySnapshot) {
        guard id == nil || library.photos(in: albumID).contains(where: { $0.id == id }) else { return }
        photoID = id
    }
}

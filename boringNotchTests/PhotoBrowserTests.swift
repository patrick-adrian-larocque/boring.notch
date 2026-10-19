// SPDX-License-Identifier: GPL-3.0-only

import XCTest
@testable import boringNotch

final class PhotoBrowserTests: XCTestCase {
    private let library = PhotoLibrarySnapshot(
        photos: [
            PhotoBrowserItem(id: "one", title: "First", symbolName: "photo"),
            PhotoBrowserItem(id: "two", title: "Second", symbolName: "photo"),
            PhotoBrowserItem(id: "three", title: "Third", symbolName: "photo")
        ],
        albums: [
            PhotoBrowserAlbum(id: "first", title: "First album", photoIDs: ["three", "one", "one", "missing"]),
            PhotoBrowserAlbum(id: "second", title: "Second album", photoIDs: ["one", "two"]),
            PhotoBrowserAlbum(id: "empty", title: "Empty album", photoIDs: [])
        ]
    )

    func testAllPhotosIncludesAssetsWithoutRequiringAnAlbum() {
        XCTAssertEqual(library.photos(in: nil).map(\.id), ["one", "two", "three"])
    }

    func testAlbumMembershipPreservesLibraryOrderAndIgnoresRepeatedOrMissingReferences() {
        XCTAssertEqual(library.photos(in: "first").map(\.id), ["one", "three"])
    }

    func testSameAssetCanAppearInMultipleAlbumsWithoutChangingTheLibrary() {
        var selection = PhotoBrowserSelection()
        let original = library
        selection.selectAlbum("first", in: library)
        selection.selectPhoto("one", in: library)
        selection.selectAlbum("second", in: library)
        XCTAssertEqual(library.photos(in: "second").map(\.id), ["one", "two"])
        XCTAssertEqual(library, original)
    }

    func testEmptyAndUnknownAlbumsDoNotLeakTheWholeLibrary() {
        XCTAssertTrue(library.photos(in: "empty").isEmpty)
        XCTAssertTrue(library.photos(in: "missing").isEmpty)
        XCTAssertTrue(PhotoLibrarySnapshot(photos: [], albums: []).photos(in: nil).isEmpty)
    }

    func testChangingAlbumClosesPhotoDetailAndAllPhotosCanBeRestored() {
        var selection = PhotoBrowserSelection()
        selection.selectAlbum("first", in: library)
        selection.selectPhoto("three", in: library)
        XCTAssertEqual(selection.photoID, "three")
        selection.selectAlbum("second", in: library)
        XCTAssertNil(selection.photoID)
        XCTAssertEqual(selection.albumID, "second")
        selection.selectAlbum(nil, in: library)
        XCTAssertNil(selection.albumID)
        XCTAssertEqual(library.photos(in: selection.albumID).count, 3)
    }

    func testCannotOpenAnAssetOutsideTheSelectedAlbum() {
        var selection = PhotoBrowserSelection()
        selection.selectAlbum("first", in: library)
        selection.selectPhoto("one", in: library)
        selection.selectPhoto("two", in: library)
        XCTAssertEqual(selection.photoID, "one")
        selection.selectPhoto("missing", in: library)
        XCTAssertEqual(selection.photoID, "one")
        selection.selectPhoto(nil, in: library)
        XCTAssertNil(selection.photoID)
    }

    func testInvalidAlbumDoesNotDiscardTheCurrentNavigation() {
        var selection = PhotoBrowserSelection()
        selection.selectAlbum("first", in: library)
        selection.selectPhoto("one", in: library)
        selection.selectAlbum("missing", in: library)
        XCTAssertEqual(selection.albumID, "first")
        XCTAssertEqual(selection.photoID, "one")
    }

    func testPhotoTabRequiresOptInAndKeepsExistingDestinations() {
        XCTAssertEqual(TabModel.available(shelfEnabled: true, photoPreviewEnabled: false).map(\.view), [.home, .shelf])
        XCTAssertEqual(TabModel.available(shelfEnabled: true, photoPreviewEnabled: true).map(\.view), [.home, .shelf, .photos])
    }

    func testPhotoTabDoesNotRequireShelf() {
        XCTAssertEqual(TabModel.available(shelfEnabled: false, photoPreviewEnabled: true).map(\.view), [.home, .photos])
        XCTAssertEqual(TabModel.available(shelfEnabled: false, photoPreviewEnabled: false).map(\.view), [.home])
    }

    func testChangingAvailableTabsPreservesHomeAndShelfIdentity() {
        let before = TabModel.available(shelfEnabled: true, photoPreviewEnabled: false).map(\.id)
        let after = TabModel.available(shelfEnabled: true, photoPreviewEnabled: true).prefix(2).map(\.id)
        XCTAssertEqual(before, after)
    }
}

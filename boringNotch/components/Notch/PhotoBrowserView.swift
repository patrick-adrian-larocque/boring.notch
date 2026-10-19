// SPDX-License-Identifier: GPL-3.0-only

import SwiftUI

struct PhotoBrowserView: View {
    let library: PhotoLibrarySnapshot
    @State private var selection = PhotoBrowserSelection()

    init(library: PhotoLibrarySnapshot = .sample) {
        self.library = library
    }

    private var visiblePhotos: [PhotoBrowserItem] {
        library.photos(in: selection.albumID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Photos preview", systemImage: "photo.on.rectangle")
                    .font(.caption.weight(.semibold))
                Spacer()
                Text("Sample library")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    albumButton(title: String(localized: "All"), id: nil, count: library.photos.count)
                    ForEach(library.albums) { album in
                        albumButton(title: album.title, id: album.id, count: library.photos(in: album.id).count)
                    }
                }
            }
            .scrollIndicators(.hidden)

            if let photo = visiblePhotos.first(where: { $0.id == selection.photoID }) {
                detail(for: photo)
            } else if visiblePhotos.isEmpty {
                Text("This sample album is empty.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                photoGrid
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func albumButton(title: String, id: String?, count: Int) -> some View {
        Button {
            selection.selectAlbum(id, in: library)
        } label: {
            HStack(spacing: 4) {
                Text(title)
                Text(count, format: .number)
                    .foregroundStyle(.secondary)
            }
            .font(.caption2)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(selection.albumID == id ? Color.white.opacity(0.18) : Color.white.opacity(0.06), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selection.albumID == id ? [.isSelected] : [])
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                ForEach(visiblePhotos) { photo in
                    Button {
                        selection.selectPhoto(photo.id, in: library)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: photo.symbolName)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                                .accessibilityHidden(true)
                            Text(photo.title)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help(photo.title)
                }
            }
        }
    }

    private func detail(for photo: PhotoBrowserItem) -> some View {
        HStack(spacing: 16) {
            Button {
                selection.selectPhoto(nil, in: library)
            } label: {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(.plain)
            Image(systemName: photo.symbolName)
                .font(.largeTitle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.title)
                    .font(.caption.weight(.semibold))
                Text("Sample artwork")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview {
    PhotoBrowserView()
        .frame(width: 640, height: 150)
        .preferredColorScheme(.dark)
}

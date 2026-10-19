//
//  TabSelectionView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-25.
//

import Defaults
import SwiftUI

struct TabModel: Identifiable {
    var id: NotchViews { view }
    let label: String
    let icon: String
    let view: NotchViews

    static func available(shelfEnabled: Bool, photoPreviewEnabled: Bool) -> [TabModel] {
        var result = [TabModel(label: String(localized: "Home"), icon: "house.fill", view: .home)]
        if shelfEnabled {
            result.append(TabModel(label: String(localized: "Shelf"), icon: "tray.fill", view: .shelf))
        }
        if photoPreviewEnabled {
            result.append(TabModel(label: String(localized: "Photos preview"), icon: "photo.on.rectangle", view: .photos))
        }
        return result
    }
}

struct TabSelectionView: View {
    @Default(.photoBrowserPreview) private var photoBrowserPreview
    @Default(.boringShelf) private var boringShelf
    @ObservedObject var coordinator = BoringViewCoordinator.shared
    @Namespace var animation

    private var tabs: [TabModel] {
        TabModel.available(shelfEnabled: boringShelf, photoPreviewEnabled: photoBrowserPreview)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                    TabButton(label: tab.label, icon: tab.icon, selected: coordinator.currentView == tab.view) {
                        withAnimation(.smooth) {
                            coordinator.currentView = tab.view
                        }
                    }
                    .accessibilityLabel(Text(tab.label))
                    .help(tab.label)
                    .frame(height: 26)
                    .foregroundStyle(tab.view == coordinator.currentView ? .white : .gray)
                    .background {
                        if tab.view == coordinator.currentView {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                        } else {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                                .hidden()
                        }
                    }
            }
        }
        .clipShape(Capsule())
    }
}

#Preview {
    BoringHeader().environmentObject(BoringViewModel(camera: CameraModel()))
}

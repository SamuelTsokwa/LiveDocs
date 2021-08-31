//
//  LiveDocsApp.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Firebase
import SwiftUIKit

@main
struct LiveDocsApp: App {
    @StateObject var rootCoordinator = RootCoordinator()
    @ObservedObject var deeplinker = Deeplinker()
    @State var deeplink: Deeplinker.Deeplink?
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            DefaultRootView {
                RootCoordinatorView(coordinator: rootCoordinator)
                    .environmentObject(deeplinker)

            }
            .onOpenURL { url in
                let deeplinker = Deeplinker()
                guard let deeplink = deeplinker.manage(url: url) else { return }
                self.deeplinker.deeplink = deeplink
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    self.deeplinker.deeplink = nil
                }
            }
        }
    }
}

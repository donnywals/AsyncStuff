//
//  QuickAsyncApp.swift
//  QuickAsync
//
//  Created by Donny Wals on 07/06/2021.
//

import SwiftUI

@main
struct QuickAsyncApp: App {
    let dataSource: RemoteDataSource
    let imageLoader: ImageLoader
    
    init() {
        let network = Networking()
        let provider = Authorizer(networking: network)
        self.dataSource = RemoteDataSource(network: network, authorizer: provider)
        self.imageLoader = ImageLoader(network: network)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataSource: dataSource, imageLoader: imageLoader)
        }
    }
}

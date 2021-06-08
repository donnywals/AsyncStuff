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
    init() {
        let network = Networking()
        let provider = Authorizer(networking: network)
        self.dataSource = RemoteDataSource(network: network, authorizer: provider)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dataSource: dataSource)
        }
    }
}

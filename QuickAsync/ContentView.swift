//
//  ContentView.swift
//  QuickAsync
//
//  Created by Donny Wals on 07/06/2021.
//

import SwiftUI

struct ContentView: View {
    let dataSource: RemoteDataSource
    
    var body: some View {
        Button("Load ints") {
            DispatchQueue.concurrentPerform(iterations: 10) { _ in
                async {
                    do {
                        let int = try await dataSource.loadRandomNumber()
                        print(int)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}

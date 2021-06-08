//
//  ContentView.swift
//  QuickAsync
//
//  Created by Donny Wals on 07/06/2021.
//

import SwiftUI

struct ContentView: View {
    let dataSource: RemoteDataSource
    let imageLoader: ImageLoader
    @State var num = 0
    
    var body: some View {
        VStack {
            Text("\(num)")

            Button("Load ints") {
                DispatchQueue.concurrentPerform(iterations: 10) { _ in
                    async {
                        do {
                            let int = try await dataSource.loadRandomNumber()
                            num = int
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
            Button("Load bunch of images") {
                async {
                    let urls = (1...10).map({ URL(string: "https://s3.eu-west-2.amazonaws.com/com.donnywals.combineworkshop/\($0).jpeg")! })
                    for url in urls {
                        let image = await try imageLoader.load(url)
                        print(image)
                    }
                }
            }
        }
    }
}

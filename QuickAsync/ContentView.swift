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
    @State var vc: AViewController?
    
    var body: some View {
        VStack {
            Text("\(num)")

            Button("Load ints") {
                detach {
                    dataSource.loadManyInts()
                }
            }
            
            Button("Load bunch of images") {
                let urls = (1...10).map({ URL(string: "https://s3.eu-west-2.amazonaws.com/com.donnywals.combineworkshop/\($0).jpeg")! })
                
                
                
                async {s
                    
//                    for url in urls {
//                        let image = await try imageLoader.load(url)
//                        print(image)
//                    }
                    
                    for try await image in await imageLoader.load(urls) {
                        print(image)
                    }
                }
            }
            
            Button("Do the VC Thing") {
                self.vc = AViewController()
                _ = vc?.view // load view
                async {
                    self.vc = nil
                }
            }
        }
    }
}


class AViewController: UIViewController {
    
    var task: Task.Handle<Data, Error>?
    
    deinit {
        task?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("will kick off")
        
        async { [weak self] in
            let data = try await self?.fetchData()
            print("-- async --")
            print(data)
            print(self)
            print("-- /async --")
        }
        
    }
    
    func fetchData() async throws -> Data {
        let data = try await URLSession.shared.data(from: URL(string: "https://donnywals.com")!).0
        print("-- fetchData --")
        print(data)
        print("-- /fetchData --")
        return data
    }
}

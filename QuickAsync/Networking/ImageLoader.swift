//
//  ImageLoader.swift
//  QuickAsync
//
//  Created by Donny Wals on 08/06/2021.
//

import Foundation
import UIKit

actor ImageLoader {
    private var images = [URL: UIImage]()
    let network: Networking
    
    init(network: Networking) {
        self.network = network
    }
    
    func fileURL(for url: URL) -> URL {
        let escaped = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("This should work")
        }
        
        return documents.appendingPathComponent(escaped, isDirectory: false)
    }
    
    func load(_ url: URL) async throws -> UIImage? {
        try Task.checkCancellation()
        
        if let image = images[url] {
            print("cache hit")
            return image
        }
        
        try Task.checkCancellation()
        
        if let image = await fromFileSystem(url) {
            print("file cache hit")
            return image
        }
        
        try Task.checkCancellation()
        
        let data = try await network.data(for: url)
        
        if let image = UIImage(data: data) {
            images[url] = image
            // will be Task.init later
            async {
                do {
                    try Task.checkCancellation()
                    try data.write(to: fileURL(for: url))
                    print("done writing to disk")
                } catch {
                    print("failed to write \(error)")
                }
            }
        }
        
        
        return images[url]
    }
    
    private func fromFileSystem(_ url: URL) async -> UIImage? {
        // Task.init
        let handler = async { () -> UIImage? in
            if let data = try? Data(contentsOf: fileURL(for: url)) {
                return UIImage(data: data)
            }
            
            return nil
        }
        
        return await handler.get()
    }
    
    func loadInGroup(_ urls: [URL]) async throws -> [UIImage] {
        var images = [UIImage]()
        
        try await withThrowingTaskGroup(of: UIImage.self) { group in
            // group is a sequence
            for url in urls {
                // adds work to the group
                group.async {
                    let data = try await self.network.data(for: url)
                    return UIImage(data: data)!
                }
            }
            
            for try await image in group {
                images.append(image)
            }
        }
        
        return images
    }
}

extension ImageLoader {
    func load(_ urls: [URL]) -> AsyncImageSequence {
        return AsyncImageSequence(urls, network: network)
    }
}

extension ImageLoader {
    class AsyncImageSequence: AsyncSequence, AsyncIteratorProtocol {
        typealias Element = UIImage
        typealias AsyncIterator = ImageLoader.AsyncImageSequence
        
        private var urls: [URL]
        private let network: Networking
        
        init(_ urls: [URL], network: Networking) {
            self.urls = urls
            self.network = network
        }
        
        __consuming func makeAsyncIterator() -> ImageLoader.AsyncImageSequence {
            return self
        }
        
        func next() async throws -> UIImage? {
            guard !urls.isEmpty else {
                return nil
            }
            let url = urls.removeFirst()
            let data = try await network.data(for: url)
            return UIImage(data: data)!
        }
    }
}

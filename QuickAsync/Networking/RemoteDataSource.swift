//
//  RemoteDataSource.swift
//  QuickAsync
//
//  Created by Donny Wals on 08/06/2021.
//

import Foundation

class RemoteDataSource {
    let network: Networking
    let authorizer: Authorizer
    let endpoint = URL(string: "https://www.random.org/integers/?num=1&min=1&max=1337&col=1&base=10&format=plain&rnd=new")!
    
    internal init(network: Networking, authorizer: Authorizer) {
        self.network = network
        self.authorizer = authorizer
    }
    
    func loadRandomNumber() async throws -> Int {
        let request = try await authorizer.authorize(URLRequest(url: endpoint))
        let int: Int = try await network.load(request)
        return int
    }
}

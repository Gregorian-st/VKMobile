//
//  VKAPIServiceProxy.swift
//  VKMobile
//
//  Created by Grigory Stolyarov on 11.03.2021.
//

import Foundation

class VKAPIServiceProxy: VKAPIServiceNewsInterface {
    
    let service: VKAPIService
    init (service: VKAPIService ) {
        self.service = service
    }
    
    func getNewsFeed(startFrom: String, completion: @escaping ([NewsVK], String) -> Void) {
        self.service.getNewsFeed(startFrom: startFrom, completion: completion)
        print("\(Date()) - call for getting News StartFrom: \(startFrom)")
    }
    
    func getNewsFeedRefresh(startTime: String, completion: @escaping ([NewsVK]) -> Void) {
        self.service.getNewsFeedRefresh(startTime: startTime, completion: completion)
        print("\(Date()) - call for getting News StartTime: \(startTime)")
    }
    
}

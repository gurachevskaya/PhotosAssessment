//
//  DIContainer.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 4.10.22.
//

import Foundation

protocol DIProtocol {
    func register<Service>(type: Service.Type, component: Any)
    func resolve<Service>(type: Service.Type) -> Service?
}

final class DIContainer: DIProtocol {
    
    static let shared = DIContainer()
    
    private init() {}
    
    var services: [String: Any] = [:]
    
    func register<Service>(type: Service.Type, component service: Any) {
        services["\(type)"] = service
    }
    
    func resolve<Service>(type: Service.Type) -> Service? {
        return services["\(type)"] as? Service
    }
}

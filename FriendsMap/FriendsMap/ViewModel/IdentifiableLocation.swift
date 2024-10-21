//
//  IdentifiableLocation.swift
//  FriendsMap
//
//  Created by Juno Lee on 10/21/24.
//

import Foundation
import CoreLocation


public struct IdentifiableLocation: Identifiable {
    public let id = UUID()
    public var coordinate: CLLocationCoordinate2D
    public var image: String?

  
    public init(coordinate: CLLocationCoordinate2D, image: String? = nil) {
        self.coordinate = coordinate
        self.image = image
    }
}


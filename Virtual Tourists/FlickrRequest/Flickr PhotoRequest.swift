//
//  Flickr Request.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 27/07/21.
//

import Foundation

struct JsonFlickr: Codable {
    let photos: FlickrPhotoResponse
}

struct FlickrPhotoResponse: Codable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    
    func imageURLString() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
}

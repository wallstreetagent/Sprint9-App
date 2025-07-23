//
//  Photo.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 7/1/25.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    var isLiked: Bool
  
}

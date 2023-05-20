//
//  Article.swift
//  QiitaListApp-UIKit
//
//  Created by 渡邊魁優 on 2023/04/29.
//

import Foundation

struct Article: Decodable {
    let title: String
    let user: User
    
    struct User: Decodable {
        let profileImageURL: URL?
        
        enum CodingKeys: String, CodingKey {
            case profileImageURL = "profile_image_url"
        }
    }
}




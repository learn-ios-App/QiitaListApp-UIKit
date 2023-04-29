//
//  APIError.swift
//  QiitaListApp-UIKit
//
//  Created by 渡邊魁優 on 2023/04/29.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError
    case responseError
    case decodeError
    case unknown

    var title: String {
        switch self {
        case .invalidURL:
            return "無効なURLのエラー"
        case .networkError:
            return "ネットワークエラー"
        case .responseError:
            return "レスポンスエラー"
        case .decodeError:
            return "デコードエラー"
        default:
            return "不明なエラー"
        }
    }
}

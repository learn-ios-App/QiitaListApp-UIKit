//
//  ViewController.swift
//  QiitaListApp-UIKit
//
//  Created by 渡邊魁優 on 2023/04/29.
//

import UIKit

class ViewController: UIViewController {
    
    private var articlesList: [Article] = []
    let qiitaAPIClient = QiitaAPIClient()
    
    //CellのId作成
    private let cellId = "Cell"
    
    //TableView作成
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ViewをTableViewにする
        view.addSubview(tableView)
        //サイズを全画面
        tableView.frame.size = view.frame.size
        
        //データソースの設定
        tableView.delegate = self   
        tableView.dataSource = self
        //cellIDの設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        //非同期のメソッドを呼び出す
        Task {
            await loadArticles()
        }
    }
    
    private func loadArticles() async {
        do {
            let articles = try await qiitaAPIClient.fetchArticles()
            DispatchQueue.main.async {
                self.articlesList = articles
                self.tableView.reloadData()
            }
        } catch {
            let error = error as? APIError ?? APIError.unknown
            print(error.title)
        }
    }
}

//ectensionはプロトコル適応させる時に使える
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = articlesList[indexPath.row].title
        
        qiitaAPIClient.loadImage(url: articlesList[indexPath.row].user.profileImageURL) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    content.image = UIImage(data: data)?.resizeUIImage(width: 45, height: 45)
                    cell.contentConfiguration = content
                }
            case .failure(let error):
                print("画像取得: \(error.title)")
            }
        }
        
        cell.contentConfiguration = content
                
        return cell
    }
}

extension UIImage {
    func resizeUIImage(width : CGFloat, height : CGFloat) -> UIImage? {
        // 指定された画像の大きさのコンテキストを用意.
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        // コンテキストに自身に設定された画像を描画する.
        self.draw(in: CGRectMake(0, 0, width, height))
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()?.roundedCorners()
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        return newImage
    }
    
    private func roundedCorners() -> UIImage {
        return UIGraphicsImageRenderer(size: self.size).image { context in
            let rect = context.format.bounds
            // Rectを角丸にする
            let roundedPath = UIBezierPath(roundedRect: rect, cornerRadius: 30)
            roundedPath.addClip()
            // UIImageを描画
            draw(in: rect)
        }
    }
}



import UIKit

class ViewController: UIViewController {
    
    //リストに表示するデータリスト
    private var articlesList: [Article] = []
    
    //API通信を行うためのインスタンス
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
        
        //データソース、デリゲートの設定
        tableView.delegate = self   
        tableView.dataSource = self
        //CellIDの設定
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        //非同期のメソッドを呼び出す
        Task {
            await loadArticles()
        }
    }
    
    //QiitaAPIから取得したデータをメインスレッドでViewに反映するメソッド
    @MainActor
    private func loadArticles() async {
        
        do {
            let articles = try await qiitaAPIClient.fetchArticles()
            self.articlesList = articles
            self.tableView.reloadData()
        } catch {
            let error = error as? APIError ?? APIError.unknown
            alertAction(title: "エラー", message: "\(error.title)です", action: { _ in Task { await self.loadArticles() } })
        }
    }
    
    private func alertAction(title: String, message: String, action: ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: "リトライ", style: .default, handler: action)
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
}

//ectensionはプロトコル適応させる時に使うことがある
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    //リストの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesList.count
    }
    
    //Cellの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = articlesList[indexPath.row].title
        
        //URLから取得した画像をViewに反映
        qiitaAPIClient.loadImage2(url: articlesList[indexPath.row].user.profileImageURL) { result in
            switch result {
            case .success(let data):
                Task { @MainActor in
                    content.image = UIImage(data: data)?.transformImage(width: 45, height: 45)
                    cell.contentConfiguration = content
                }
            case .failure(let error):
                print("画像取得失敗\(indexPath.row)行目: \(error.title)")
            }
        }
        
        cell.contentConfiguration = content
                
        return cell
    }
}

//UIImageに画像サイズと角を調整するメソッドを追加
extension UIImage {
    
    func transformImage(width : CGFloat, height : CGFloat) -> UIImage? {
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
            let roundedPath = UIBezierPath(roundedRect: rect, cornerRadius: 45)
            roundedPath.addClip()
            // UIImageを描画
            draw(in: rect)
        }
    }
}

//
//  ViewController.swift
//  SearchRepositoryForWantedly
//
//  Created by HideakiTouhara on 2017/07/07.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var repoList : [(description: String, url: String, starCount: Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchText.delegate = self
        searchText.placeholder = "キーワードに関連したRepositoryを表示します"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            searchRepo(keyword: searchWord)
        }
    }
    
    func searchRepo(keyword: String) {
        // urlオブジェクトの作成
        let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let URL = Foundation.URL(string: "https://api.github.com/search/repositories?q=\(keyword_encode!)")
        
        //jsonダウンロード
        let req = URLRequest(url: URL!)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {
            (data, request, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                if let items = json["items"] as? [[String:Any]] {
                    for item in items {
                        guard let description = item["description"] as? String else {
                            continue
                        }
                        
                        guard let url = item["html_url"] as? String else {
                            continue
                        }
                        
                        guard let starCount = item["stargazers_count"] as? Int else {
                            continue
                        }
                        
                        let repo = (description, url, starCount)
                        self.repoList.append(repo)
                    }
                }
                print("repoList[0] = \(self.repoList[0])")
            } catch {
                print("パースのときにエラー")
            }
        })
        task.resume()
    }


}


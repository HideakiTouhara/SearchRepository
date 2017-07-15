//
//  ViewController.swift
//  SearchRepositoryForWantedly
//
//  Created by HideakiTouhara on 2017/07/07.
//  Copyright © 2017年 HideakiTouhara. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,  SFSafariViewControllerDelegate{
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var repoList : [(description: String, url: String, starCount: Int, language: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchText.delegate = self
        
        searchText.placeholder = "キーワードに関連したRepositoryを表示します"
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        setBackgroundImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- SearchBar

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        self.searchRepo()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.searchRepo()
        })
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        self.repoList.removeAll()
        tableView.reloadData()
        return true
    }
    
    func searchRepo() {
        let keyword = searchText.text!
        
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
                
                self.repoList.removeAll()
                
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
                        
                        guard let langauge = item["language"] as? String else {
                            continue
                        }
                        
                        let repo = (description, url, starCount, langauge)
                        self.repoList.append(repo)
                    }
                }
                self.tableView.reloadData()
                self.activityIndicator.alpha = 0
                self.activityIndicator.stopAnimating()

            } catch {
                print("パースのときにエラー")
            }
        })
        task.resume()
    }
    
    //MARK:- TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // レポジトリ名をセルに代入
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepoCell", for: indexPath)
        cell.textLabel?.text = repoList[indexPath.row].description
        cell.detailTextLabel?.text = repoList[indexPath.row].language
        
        // スターカウントを追加
        let starLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        starLabel.text = "★\(self.repoList[indexPath.row].starCount)"
        starLabel.textAlignment = .left
        starLabel.sizeToFit()
        cell.accessoryView = starLabel
        
        // tableviewの背景画像表示のため、cellの背景を透明に
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let urlToLink = URL(string: repoList[indexPath.row].url)
        
        let safariViewController = SFSafariViewController(url: urlToLink!)
        
        safariViewController.delegate = self
        
        present(safariViewController, animated: true, completion: nil)
    }
    
    func setBackgroundImage() {
        
        let image = UIImage(named: "tableview_background.png")
        
        let imageView = UIImageView(image: image)
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height)
        
        self.tableView.backgroundView = imageView
    }
    
    //MARK:- Safari
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }


}


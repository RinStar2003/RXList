//
//  ViewController.swift
//  rxSwiftApiTest
//
//  Created by мас on 16.09.2022.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UIScrollViewDelegate {
    
    private var viewModel = ViewModel()
    
    private var bag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        viewModel.fetchUsers()
        bindTableView()
    }
    
    func bindTableView() {
        
        tableView.rx.setDelegate(self).disposed(by: bag)
        viewModel.users.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UserTableViewCell.self))
        { (row, item, cell) in
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = "\(item.id)"
            }.disposed(by: bag)
        }
    }
    
    extension ViewController: UITableViewDelegate {}
    
    class ViewModel {
        var users = BehaviorSubject(value: [User]())
        
        func fetchUsers() {
            guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    return
                }
                do {
                    let responseData = try JSONDecoder().decode([User].self, from: data)
                    self.users.on(.next(responseData))
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
    struct User: Codable {
        let userID, id: Int
        let title, body: String
        
        enum CodingKeys: String, CodingKey {
            case userID = "userId"
            case id, title, body
        }
    }

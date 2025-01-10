//
//  ViewController.swift
//  TienYu_Combine
//
//  Created by Kedia on 2025/1/9.
//

import UIKit
import Combine

class ViewController: UIViewController {

    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    private let viewModel = ViewControllerVM()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "新聞清單"
        view.backgroundColor = .white

        setupSearchBar()
        setupTableView()
        setupBindings()

        // 載入新聞
        viewModel.fetchNews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupSearchBar() {
        searchBar.placeholder = "搜尋新聞"
        searchBar.delegate = self  // 透過 UISearchBarDelegate 監聽使用者輸入
        navigationItem.titleView = searchBar
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // 註冊或自訂 cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        // 訂閱 filteredNews，每當它更新就 reload tableView
        viewModel.$filteredNews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredNews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let news = viewModel.filteredNews[indexPath.row]
        cell.textLabel?.text = "\(news.title)\n\(news.content)"
        cell.textLabel?.numberOfLines = 0  // 允許多行顯示
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 將使用者輸入的文字傳給 ViewModel
        viewModel.searchText = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 若有 cancel button，可清空
        searchBar.text = ""
        viewModel.searchText = ""
        searchBar.resignFirstResponder()
    }
}

//
//  ViewControllerVM.swift
//  TienYu_Combine
//
//  Created by Kedia on 2025/1/10.
//

import Combine
import Foundation

struct TUNewsModel: Decodable {
    let id: Int
    let title: String
    let content: String
}

class ViewControllerVM {
    // 原始的新聞資料
    private var newsList: [TUNewsModel] = []

    // 搜尋相關
    @Published var searchText: String = ""
    @Published var filteredNews: [TUNewsModel] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // 訂閱 searchText，當文字改變時，0.5 秒後再執行篩選邏輯 (防抖)
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.filteredNews = self.newsList
                } else {
                    self.filteredNews = self.newsList.filter {
                        $0.title.localizedCaseInsensitiveContains(text) ||
                        $0.content.localizedCaseInsensitiveContains(text)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func fetchNews() {
        // 模擬從伺服器抓取 JSON
        let jsonString = """
        [
            {
                "id": 1,
                "title": "Swift 5.9 Released",
                "content": "Swift 5.9 brings amazing features."
            },
            {
                "id": 2,
                "title": "Combine Framework Guide",
                "content": "Learn how to use Combine effectively."
            },
            {
                "id": 3,
                "title": "iOS 17 New Features",
                "content": "iOS 17 introduces incredible changes."
            }
        ]
        """
        let data = Data(jsonString.utf8)

        do {
            let newsArray = try JSONDecoder().decode([TUNewsModel].self, from: data)
            self.newsList = newsArray
            self.filteredNews = newsArray
        } catch {
            print("JSON 解析錯誤: \(error)")
        }
    }
}

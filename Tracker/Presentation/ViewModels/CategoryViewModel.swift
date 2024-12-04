//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import Foundation

final class CategoryViewModel {
    var onCategoriesUpdated: (() -> Void)?

    private(set) var categories: [TrackerCategory] = []

    private let provider = DataProvider()

    init() {
        fetchCategories()
        provider.delegate = self
    }

    func fetchCategories() {
        categories = provider.getAllTrackersWithCategories()
        onCategoriesUpdated?()
    }

    func addCategory(name: String) {
        provider.addCategory(name: name)
    }

    func deleteCategory(at index: Int) {
        let category = categories[index]
        if let category = provider.getAllTrackersWithCategories().first(where: {
            $0.id == category.id
        }) {
            provider.deleteCategory(category)
        }
    }
}

extension CategoryViewModel: DataProviderDelegate {
    func dataDidChange() {
        fetchCategories()
    }
}

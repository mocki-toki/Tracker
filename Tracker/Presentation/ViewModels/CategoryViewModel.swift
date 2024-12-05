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

    func updateCategory(category: TrackerCategory, newName: String) {
        provider.updateCategory(category, newName: newName)
    }

    func deleteCategory(category: TrackerCategory) {
        provider.deleteCategory(category)
    }
}

extension CategoryViewModel: DataProviderDelegate {
    func dataDidChange() {
        fetchCategories()
    }
}

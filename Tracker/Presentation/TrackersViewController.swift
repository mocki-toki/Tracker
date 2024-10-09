//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Properties

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = .init()
    private var searchText: String = ""

    // MARK: - UI Components

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.ypAdd, for: .normal)
        button.tintColor = .ypBlack
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: .ypEmptyTrackersPlaceholder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CategoryHeader")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadData()
        filterTrackers()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        [addButton, datePicker, titleLabel, searchBar, collectionView, placeholderView].forEach { view.addSubview($0) }

        [placeholderImageView, placeholderLabel].forEach { placeholderView.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor)
        ])
    }

    // MARK: - Data Management

    private func loadData() {
        categories = [
            TrackerCategory(title: "Здоровье", trackers: [
                Tracker(
                    id: UUID(),
                    name: "Медитация", emoji: "🧘‍♂️", color: .systemBlue,
                    schedule: Set(Weekday.allCases)
                ),
                Tracker(
                    id: UUID(),
                    name: "Пробежка", emoji: "🏃‍♂️", color: .systemGreen,
                    schedule: [.monday, .wednesday, .friday]
                )
            ]),
            TrackerCategory(title: "Развитие", trackers: [
                Tracker(
                    id: UUID(),
                    name: "Чтение", emoji: "📚", color: .systemPurple,
                    schedule: Set(Weekday.allCases)
                )
            ])
        ]
    }

    private func filterTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let currentWeekday = weekday == 1 ? Weekday.sunday : Weekday(rawValue: weekday - 1)!

        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule?.contains(currentWeekday) ?? true
                let matchesSearch = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                return matchesSchedule && matchesSearch
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

        updatePlaceholderVisibility()
        collectionView.reloadData()
    }

    private func updatePlaceholderVisibility() {
        placeholderView.isHidden = !visibleCategories.isEmpty
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.onTypeSelected = { [weak self] type in
            self?.presentNewTrackerViewController(for: type)
        }
        typeSelectionVC.modalPresentationStyle = .pageSheet
        present(typeSelectionVC, animated: true)
    }

    private func presentNewTrackerViewController(for type: NewTrackerViewController.TrackerType) {
        let newTrackerVC = NewTrackerViewController(type: type)
        newTrackerVC.onTrackerCreated = { [weak self] newTracker in
            self?.addNewTracker(newTracker)
        }
        newTrackerVC.modalPresentationStyle = .pageSheet

        dismiss(animated: true) { [weak self] in
            self?.present(newTrackerVC, animated: true)
        }
    }

    private func addNewTracker(_ tracker: Tracker) {
        let categoryName = "Общее"
        if let index = categories.firstIndex(where: { $0.title == categoryName }) {
            let existingCategory = categories[index]
            let updatedTrackers = existingCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: categoryName, trackers: updatedTrackers)
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: categoryName, trackers: [tracker])
            categories.append(newCategory)
        }

        filterTrackers()
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterTrackers()
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterTrackers()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompleted(tracker)
        let completedDays = completedDays(for: tracker)

        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)

        cell.onPlusButtonTap = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
            collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath) as? CategoryHeaderView
        else {
            return UICollectionReusableView()
        }

        headerView.text = visibleCategories[indexPath.section].title
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        let interItemSpacing: CGFloat = 9
        let availableWidth = collectionView.frame.width - insets.left - insets.right - interItemSpacing
        let cellWidth = availableWidth / 2
        let cellHeight: CGFloat = 148
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// MARK: - Tracker Completion Handling

extension TrackersViewController {
    private func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
    }

    private func completedDays(for tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    private func toggleTrackerCompletion(_ tracker: Tracker) {
        let currentDate = Date()
        if self.currentDate > currentDate {
            let alert = UIAlertController(title: "Ошибка", message: "Нельзя отметить трекер на будущую дату", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
            completedTrackers.remove(at: index)
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: currentDate)
            completedTrackers.append(newRecord)
        }
    }
}

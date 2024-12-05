//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        enum Texts {
            static let trackers = NSLocalizedString(
                "Trackers", comment: "Title for trackers section or tab")
            static let search = NSLocalizedString(
                "Search", comment: "Title for search functionality")
            static let whatToTrack = NSLocalizedString(
                "WhatToTrack", comment: "Prompt asking what to track")
            static let error = NSLocalizedString("Error", comment: "Generic error title")
            static let cannotMarkFutureDate = NSLocalizedString(
                "CannotMarkFutureDate",
                comment: "Error message when trying to mark a tracker for a future date")
            static let ok = "OK"
        }

        enum Fonts {
            static let titleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
            static let placeholderFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        }

        enum Colors {
            static let background = UIColor.white
            static let tint = UIColor.ypBlack
            static let placeholderText = UIColor.ypBlack
        }

        enum Sizes {
            static let addButtonTopPadding: CGFloat = 16
            static let addButtonLeadingPadding: CGFloat = 16
            static let datePickerTopPadding: CGFloat = 16
            static let datePickerTrailingPadding: CGFloat = 16
            static let titleTopPadding: CGFloat = 16
            static let titleLeadingPadding: CGFloat = 16
            static let searchBarTopPadding: CGFloat = 8
            static let searchBarHorizontalPadding: CGFloat = 8
            static let collectionViewTopPadding: CGFloat = 8
            static let placeholderImageSize: CGFloat = 80
            static let placeholderLabelTopPadding: CGFloat = 8
            static let cellWidth: CGFloat = 2
            static let cellHeight: CGFloat = 148
            static let headerHeight: CGFloat = 18
            static let sectionInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            static let interItemSpacing: CGFloat = 9
            static let lineSpacing: CGFloat = 16
        }
    }

    // MARK: - Properties

    private let dataProvider: DataProvider
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = .init()
    private var searchText: String = ""

    // MARK: - Initialization

    init() {
        self.dataProvider = DataProvider()
        super.init(nibName: nil, bundle: nil)
        self.dataProvider.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Components

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.ypAdd, for: .normal)
        button.tintColor = Constants.Colors.tint
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
        label.text = Constants.Texts.trackers
        label.font = Constants.Fonts.titleFont
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.Texts.search
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
        label.text = Constants.Texts.whatToTrack
        label.textAlignment = .center
        label.font = Constants.Fonts.placeholderFont
        label.textColor = Constants.Colors.placeholderText
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Constants.Colors.background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(
            CategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "CategoryHeader")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadTrackers()
        filterTrackers()
    }

    // MARK: - Data Management

    private func loadTrackers() {
        categories = dataProvider.getAllTrackersWithCategories()
        completedTrackers = dataProvider.getAllRecords()
        filterTrackers()
    }

    private func filterTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let currentWeekday = weekday == 1 ? Weekday.sunday : Weekday(rawValue: weekday - 1)!

        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule?.contains(currentWeekday) ?? true
                let matchesSearch =
                    searchText.isEmpty
                    || tracker.name.lowercased().contains(searchText.lowercased())
                return matchesSchedule && matchesSearch
            }
            return filteredTrackers.isEmpty
                ? nil
                : TrackerCategory(
                    id: UUID(),
                    name: category.name,
                    trackers: filteredTrackers
                )
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

    private func presentNewTrackerViewController(for type: TrackerType) {
        let newTrackerVC = NewTrackerViewController(type: type)
        newTrackerVC.onTrackerCreated = { [weak self] newTracker, selectedCategory in
            self?.addNewTracker(newTracker, category: selectedCategory)
        }
        newTrackerVC.modalPresentationStyle = .pageSheet

        dismiss(animated: true) { [weak self] in
            self?.present(newTrackerVC, animated: true)
        }
    }

    private func addNewTracker(_ tracker: Tracker, category selectedCategory: TrackerCategory) {
        dataProvider.addTracker(tracker, category: selectedCategory)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterTrackers()
    }

    private func presentDeleteAlert(for tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "Уверены, что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.dataProvider.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - DataProviderDelegate

extension TrackersViewController: DataProviderDelegate {
    func dataDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.loadTrackers()
        }
    }
}

// MARK: - UIConfigurable

extension TrackersViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background

        for item in [addButton, datePicker, titleLabel, searchBar, collectionView, placeholderView]
        {
            view.addSubview(item)
        }

        [placeholderImageView, placeholderLabel].forEach { placeholderView.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.Sizes.addButtonTopPadding),
            addButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Sizes.addButtonLeadingPadding),

            datePicker.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.Sizes.datePickerTopPadding),
            datePicker.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.Sizes.datePickerTrailingPadding),

            titleLabel.topAnchor.constraint(
                equalTo: addButton.bottomAnchor, constant: Constants.Sizes.titleTopPadding),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Sizes.titleLeadingPadding),

            searchBar.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Constants.Sizes.searchBarTopPadding),
            searchBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Sizes.searchBarHorizontalPadding),
            searchBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.Sizes.searchBarHorizontalPadding),

            collectionView.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor, constant: Constants.Sizes.collectionViewTopPadding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderImageView.widthAnchor.constraint(
                equalToConstant: Constants.Sizes.placeholderImageSize),
            placeholderImageView.heightAnchor.constraint(
                equalToConstant: Constants.Sizes.placeholderImageSize),

            placeholderLabel.topAnchor.constraint(
                equalTo: placeholderImageView.bottomAnchor,
                constant: Constants.Sizes.placeholderLabelTopPadding),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),
        ])
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

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackersViewCell
        else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompleted(tracker)
        let completedDays = completedDays(for: tracker)

        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)

        cell.onPlusButtonTap = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadItems(at: [indexPath])
            }
        }

        cell.onMenuAction = { [weak self] action in
            switch action {
            case .delete:
                self?.presentDeleteAlert(for: tracker)
            }
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: "CategoryHeader", for: indexPath)
                as? CategoryHeaderView
        else {
            return UICollectionReusableView()
        }

        headerView.text = visibleCategories[indexPath.section].name
        return headerView
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let insets = Constants.Sizes.sectionInsets
        let interItemSpacing = Constants.Sizes.interItemSpacing
        let availableWidth =
            collectionView.frame.width - insets.left - insets.right - interItemSpacing
        let cellWidth = availableWidth / Constants.Sizes.cellWidth
        return CGSize(width: cellWidth, height: Constants.Sizes.cellHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.Sizes.headerHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return Constants.Sizes.sectionInsets
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.Sizes.interItemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Constants.Sizes.lineSpacing
    }

    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        dataProvider.deleteTracker(tracker)
    }
}

// MARK: - Tracker Completion Handling

extension TrackersViewController {
    private func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return completedTrackers.contains {
            $0.tracker.id == tracker.id
                && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
    }

    private func completedDays(for tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.tracker.id == tracker.id }.count
    }

    private func toggleTrackerCompletion(_ tracker: Tracker) {
        if currentDate > Date() {
            let alert = UIAlertController(
                title: Constants.Texts.error, message: Constants.Texts.cannotMarkFutureDate,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Texts.ok, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        dataProvider.switchTrackerRecord(for: tracker, on: currentDate)
    }
}

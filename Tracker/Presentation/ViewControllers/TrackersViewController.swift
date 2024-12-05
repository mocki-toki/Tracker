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
            static let background = UIColor.ypWhite
            static let tint = UIColor.ypBlack
            static let placeholderText = UIColor.ypBlack
            static let filtersButtonBackground = UIColor.ypBlue
        }

        enum Sizes {
            static let cornerRadius: CGFloat = 16
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
            static let filtersButtonInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
            static let interItemSpacing: CGFloat = 9
            static let lineSpacing: CGFloat = 16

            static let filtersButtonWidth: CGFloat = 44
            static let filtersButtonHeight: CGFloat = 44
            static let filtersButtonBottomPadding: CGFloat = 16
            static let filtersButtonTrailingPadding: CGFloat = 16
        }
    }

    // MARK: - Properties

    private let dataProvider: DataProvider
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = .init()
    private var searchText: String = ""
    private var selectedFilter: FilterOption = .today

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

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.contentEdgeInsets = Constants.Sizes.filtersButtonInsets
        button.backgroundColor = Constants.Colors.filtersButtonBackground
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadTrackers()
        filterTrackers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MetricaService.shared.reportEvent(event: "open", screen: "Main")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent || self.isBeingDismissed {
            MetricaService.shared.reportEvent(event: "close", screen: "Main")
        }
    }

    // MARK: - Data Management

    private func loadTrackers() {
        categories = dataProvider.getAllTrackersWithCategories()
        completedTrackers = dataProvider.getAllRecords()
        filterTrackers()
        setupCollectionViewInsets()

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let currentWeekday = weekday == 1 ? Weekday.sunday : Weekday(rawValue: weekday - 1)!
        let hasTrackersForSelectedDay = categories.flatMap { $0.trackers }.contains { tracker in
            tracker.schedule?.contains(currentWeekday) ?? false
        }
        filtersButton.isHidden = !hasTrackersForSelectedDay
    }

    // MARK: - Filtering Logic

    private func filterTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let currentWeekday = weekday == 1 ? Weekday.sunday : Weekday(rawValue: weekday - 1)!

        let pinnedTrackers = categories.flatMap { $0.trackers }.filter { tracker in
            tracker.isPinned && (tracker.schedule?.contains(currentWeekday) ?? true)
        }

        var filteredCategories: [TrackerCategory] = []
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(
                id: UUID(), name: "Закрепленные", trackers: pinnedTrackers)
            filteredCategories.append(pinnedCategory)
        }

        let otherCategories = categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                guard !tracker.isPinned else { return false }
                let matchesSchedule = tracker.schedule?.contains(currentWeekday) ?? true
                let matchesSearch =
                    searchText.isEmpty
                    || tracker.name.lowercased().contains(searchText.lowercased())
                return matchesSchedule && matchesSearch
            }

            return filteredTrackers.isEmpty
                ? nil
                : TrackerCategory(
                    id: category.id,
                    name: category.name,
                    trackers: filteredTrackers
                )
        }

        filteredCategories.append(contentsOf: otherCategories)

        switch selectedFilter {
        case .all:
            break
        case .today:
            currentDate = Date()

            if !Calendar.current.isDate(Date(), inSameDayAs: datePicker.date) {
                datePicker.date = currentDate
                DispatchQueue.main.async {
                    self.filterTrackers()
                }
            }
        case .completed:
            filteredCategories = filteredCategories.map { category in
                let completedTrackers = category.trackers.filter { tracker in
                    return isTrackerCompleted(tracker)
                }
                return TrackerCategory(
                    id: category.id, name: category.name, trackers: completedTrackers)
            }.filter { !$0.trackers.isEmpty }
        case .incomplete:
            filteredCategories = filteredCategories.map { category in
                let incompleteTrackers = category.trackers.filter { tracker in
                    return !isTrackerCompleted(tracker)
                }
                return TrackerCategory(
                    id: category.id, name: category.name, trackers: incompleteTrackers)
            }.filter { !$0.trackers.isEmpty }
        }

        visibleCategories = filteredCategories
        updatePlaceholderVisibility()
        collectionView.reloadData()

        let hasTrackersForSelectedDay = categories.flatMap { $0.trackers }.contains { tracker in
            tracker.schedule?.contains(currentWeekday) ?? false
        }
        filtersButton.isHidden = !hasTrackersForSelectedDay
    }

    private func updatePlaceholderVisibility() {
        if visibleCategories.isEmpty {
            if selectedFilter == .completed || selectedFilter == .incomplete {
                placeholderLabel.text = "Ничего не найдено"
                placeholderImageView.image = UIImage.ypEmptyResultsPlaceholder
            } else {
                placeholderLabel.text = Constants.Texts.whatToTrack
                placeholderImageView.image = UIImage.ypEmptyTrackersPlaceholder
            }
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        MetricaService.shared.reportEvent(event: "click", screen: "Main", item: "add_track")
        let typeSelectionVC = TrackerTypeSelectionViewController()
        typeSelectionVC.onTypeSelected = { [weak self] type in
            self?.presentTrackerFormViewController(for: type)
        }
        typeSelectionVC.modalPresentationStyle = .pageSheet
        present(typeSelectionVC, animated: true)
    }

    private func presentTrackerFormViewController(for type: TrackerType) {
        let newTrackerVC = TrackerFormViewController(type: type)
        newTrackerVC.onDone = { [weak self] newTracker, selectedCategory in
            self?.dataProvider.addTracker(newTracker, category: selectedCategory)
        }
        newTrackerVC.modalPresentationStyle = .pageSheet

        dismiss(animated: true) { [weak self] in
            self?.present(newTrackerVC, animated: true)
        }
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date

        if selectedFilter == .today && !Calendar.current.isDate(Date(), inSameDayAs: currentDate) {
            selectedFilter = .all
        } else if selectedFilter == .all
            && Calendar.current.isDate(Date(), inSameDayAs: currentDate)
        {
            selectedFilter = .today
        }

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

    @objc private func filtersButtonTapped() {
        MetricaService.shared.reportEvent(event: "click", screen: "Main", item: "filter")
        let filtersVC = FiltersViewController(selectedFilter: selectedFilter)
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.selectedFilter = filter
            self?.filterTrackers()

            guard let self = self else { return }
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: self.currentDate)
            let currentWeekday = weekday == 1 ? Weekday.sunday : Weekday(rawValue: weekday - 1)!
            let hasTrackersForSelectedDay = self.categories.flatMap { $0.trackers }.contains {
                tracker in
                tracker.schedule?.contains(currentWeekday) ?? false
            }
            self.filtersButton.isHidden = !hasTrackersForSelectedDay
        }

        filtersVC.modalPresentationStyle = .pageSheet

        dismiss(animated: true) { [weak self] in
            self?.present(filtersVC, animated: true)
        }
    }

    // MARK: - UIConfigurable

    func setupUI() {
        view.backgroundColor = Constants.Colors.background

        for item in [
            addButton, datePicker, titleLabel, searchBar, collectionView, placeholderView,
            filtersButton,
        ] {
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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

            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor, constant: -Constants.Sizes.filtersButtonBottomPadding),
        ])
    }

    private func setupCollectionViewInsets() {
        collectionView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: Constants.Sizes.filtersButtonHeight + Constants.Sizes.filtersButtonBottomPadding
                + Constants.Sizes.collectionViewTopPadding,
            right: 0
        )
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
            guard let self = self else { return }

            switch action {
            case .pin:
                self.dataProvider.pinTracker(tracker)
                self.filterTrackers()
            case .unpin:
                self.dataProvider.unpinTracker(tracker)
                self.filterTrackers()
            case .edit:
                self.editTracker(tracker, category: self.visibleCategories[indexPath.section])
            case .delete:
                self.presentDeleteAlert(for: tracker)
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

    private func editTracker(_ tracker: Tracker, category: TrackerCategory) {
        MetricaService.shared.reportEvent(event: "click", screen: "Main", item: "edit")
        let editTrackerVC = TrackerFormViewController(
            editedTracker: (tracker, completedDays(for: tracker)), category: category)
        editTrackerVC.onDone = { [weak self] newTracker, selectedCategory in
            self?.dataProvider.updateTracker(newTracker, category: selectedCategory)
        }
        editTrackerVC.modalPresentationStyle = .pageSheet

        dismiss(animated: true) { [weak self] in
            self?.present(editTrackerVC, animated: true)
        }
    }

    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        MetricaService.shared.reportEvent(event: "click", screen: "Main", item: "delete")
        dataProvider.deleteTracker(tracker)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MetricaService.shared.reportEvent(event: "click", screen: "Main", item: "track")
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

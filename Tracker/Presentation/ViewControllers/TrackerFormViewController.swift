//
//  TrackerFormViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class TrackerFormViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        enum Texts {
            static let enterTrackName = NSLocalizedString(
                "EnterTrackName", comment: "Enter track name hint")
            static let cancel = NSLocalizedString("Cancel", comment: "Cancel button")
            static let create = NSLocalizedString("Create", comment: "Create button")
            static let save = NSLocalizedString("Save", comment: "Save button")
            static let newHabit = NSLocalizedString(
                "NewHabit", comment: "Title for creating a new habit")
            static let newIrregularEvent = NSLocalizedString(
                "NewIrregularEvent", comment: "Title for creating a new irregular event")
            static let editTracker = NSLocalizedString(
                "EditTracker", comment: "Title for editing a tracker")
            static let schedule = NSLocalizedString(
                "Schedule", comment: "Button for schedule section")
            static let category = NSLocalizedString(
                "Category", comment: "Button for category selection")
            static let emoji = NSLocalizedString("Emoji", comment: "Subtitle for emoji selection")
            static let color = NSLocalizedString("Color", comment: "Subtitle for color selection")
        }

        enum Sizes {
            static let cornerRadius: CGFloat = 16
            static let textFieldHeight: CGFloat = 75
            static let buttonHeight: CGFloat = 60
            static let tableViewCellHeight: CGFloat = 75
            static let headerHeight: CGFloat = 42
        }

        enum Paddings {
            static let titleTopPadding: CGFloat = 27
            static let textFieldTopPadding: CGFloat = 38
            static let tableViewTopPadding: CGFloat = 24
            static let horizontalPadding: CGFloat = 16
            static let buttonBottomPadding: CGFloat = 16
            static let buttonSpacing: CGFloat = 8
        }

        enum Colors {
            static let background = UIColor.ypWhite
            static let textFieldBackground = UIColor.ypBackground
            static let cellBackground = UIColor.ypBackground
            static let cancelButtonBorder = UIColor.ypRed
            static let doneButtonBackground = UIColor.ypBlack
            static let doneButtonText = UIColor.ypWhite
            static let detailTextColor = UIColor.ypGray
            static let headerTextColor = UIColor.ypBlack
        }

        enum Fonts {
            static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            static let cellTextFont = UIFont.systemFont(ofSize: 17)
            static let headerFont = UIFont.systemFont(ofSize: 19, weight: .heavy)
        }
    }

    // MARK: - Properties

    private let editedTracker: (tracker: Tracker, completedDays: Int)?
    private let trackerType: TrackerType
    private var selectedSchedule: Set<Weekday> = []
    private var selectedCategory: TrackerCategory?
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪",
    ]
    private let colorNames: [String] = Array(1...18).map {
        "YP Palette \($0)"
    }

    private var selectedEmoji: String {
        didSet {
            updateDoneButtonState()
        }
    }

    private var selectedColorName: String {
        didSet {
            updateDoneButtonState()
        }
    }

    var onDone: ((Tracker, TrackerCategory) -> Void)?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.Texts.enterTrackName
        textField.backgroundColor = Constants.Colors.textFieldBackground
        textField.layer.cornerRadius = Constants.Sizes.cornerRadius
        textField.leftView = UIView(
            frame: CGRect(
                x: 0, y: 0, width: Constants.Paddings.horizontalPadding,
                height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = Constants.Sizes.cornerRadius
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: Constants.Paddings.horizontalPadding, bottom: 0,
            right: Constants.Paddings.horizontalPadding)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(
            width: view.frame.width, height: Constants.Sizes.headerHeight)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        collection.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collection.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collection.register(
            TrackerHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderReusableView.reuseIdentifier)
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.cancel, for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = Constants.Colors.cancelButtonBorder.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(
            editedTracker != nil ? Constants.Texts.save : Constants.Texts.create, for: .normal)
        button.setTitleColor(Constants.Colors.doneButtonText, for: .normal)
        button.backgroundColor = Constants.Colors.doneButtonBackground
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Initialization

    init(type: TrackerType) {
        self.trackerType = type
        self.editedTracker = nil
        self.selectedEmoji = emojis.first!
        self.selectedColorName = colorNames.first!
        super.init(nibName: nil, bundle: nil)
    }

    init(editedTracker: (tracker: Tracker, completedDays: Int), category: TrackerCategory) {
        self.editedTracker = editedTracker
        self.trackerType = editedTracker.tracker.schedule != nil ? .habit : .irregularEvent
        self.selectedEmoji = editedTracker.tracker.emoji
        self.selectedColorName = editedTracker.tracker.colorName
        self.selectedSchedule = editedTracker.tracker.schedule ?? []
        self.selectedCategory = category
        super.init(nibName: nil, bundle: nil)
        self.nameTextField.text = editedTracker.tracker.name
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureForTrackerType()
        setupKeyboardDismissal()
        collectionView.reloadData()
    }

    // MARK: - UI Setup

    private func configureForTrackerType() {
        if let editedTracker = editedTracker {
            titleLabel.text = Constants.Texts.editTracker
            daysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("Days", comment: "Number of days"),
                editedTracker.completedDays
            )
            daysLabel.isHidden = false
        } else {
            switch trackerType {
            case .habit:
                titleLabel.text = Constants.Texts.newHabit
            case .irregularEvent:
                titleLabel.text = Constants.Texts.newIrregularEvent
            }
            daysLabel.isHidden = true
        }
    }

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)

        nameTextField.delegate = self
    }

    // MARK: - Actions

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func doneButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }

        let tracker: Tracker
        if let editedTracker = editedTracker {
            tracker = Tracker(
                id: editedTracker.tracker.id,
                name: name,
                emoji: selectedEmoji,
                colorName: selectedColorName,
                schedule: trackerType == .habit ? selectedSchedule : nil,
                isPinned: false
            )
        } else {
            tracker = Tracker(
                id: UUID(),
                name: name,
                emoji: selectedEmoji,
                colorName: selectedColorName,
                schedule: trackerType == .habit ? selectedSchedule : nil,
                isPinned: false
            )
        }

        dismiss(animated: true) { [weak self] in
            self?.onDone?(tracker, self!.selectedCategory!)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        updateDoneButtonState()
    }

    private func updateDoneButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleValid = trackerType == .irregularEvent || !selectedSchedule.isEmpty
        let isCategoryValid = selectedCategory != nil
        doneButton.isEnabled = isNameValid && isScheduleValid && isCategoryValid
        doneButton.layer.opacity = doneButton.isEnabled ? 1 : 0.5
    }
}

// MARK: - UIConfigurable

extension TrackerFormViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, daysLabel, nameTextField, tableView, collectionView, cancelButton, doneButton]
            .forEach {
                contentView.addSubview($0)
            }

        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateDoneButtonState()
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: Constants.Paddings.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableView.topAnchor.constraint(
                equalTo: nameTextField.bottomAnchor,
                constant: Constants.Paddings.tableViewTopPadding),
            tableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            tableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -Constants.Paddings.horizontalPadding
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: trackerType == .habit
                    ? Constants.Sizes.tableViewCellHeight * 2 : Constants.Sizes.tableViewCellHeight),

            collectionView.topAnchor.constraint(
                equalTo: tableView.bottomAnchor, constant: Constants.Paddings.tableViewTopPadding),
            collectionView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            collectionView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -Constants.Paddings.horizontalPadding
            ),
            collectionView.heightAnchor.constraint(equalToConstant: 460),

            cancelButton.topAnchor.constraint(
                equalTo: collectionView.bottomAnchor, constant: Constants.Paddings.buttonSpacing),
            cancelButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight),
            cancelButton.widthAnchor.constraint(equalTo: doneButton.widthAnchor),

            doneButton.topAnchor.constraint(
                equalTo: collectionView.bottomAnchor, constant: Constants.Paddings.buttonSpacing),
            doneButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -Constants.Paddings.horizontalPadding
            ),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight),
            doneButton.leadingAnchor.constraint(
                equalTo: cancelButton.trailingAnchor, constant: Constants.Paddings.buttonSpacing),
            doneButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -Constants.Paddings.buttonBottomPadding
            ),
        ]

        if editedTracker == nil {
            constraints += [
                nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
                nameTextField.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: Constants.Paddings.horizontalPadding),
                nameTextField.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Constants.Paddings.horizontalPadding),
                nameTextField.heightAnchor.constraint(
                    equalToConstant: Constants.Sizes.textFieldHeight),
            ]
        } else {
            constraints += [
                daysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
                daysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

                nameTextField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 40),
                nameTextField.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: Constants.Paddings.horizontalPadding),
                nameTextField.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -Constants.Paddings.horizontalPadding),
                nameTextField.heightAnchor.constraint(
                    equalToConstant: Constants.Sizes.textFieldHeight),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TrackerFormViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType == .habit ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = Constants.Colors.cellBackground
        cell.textLabel?.font = Constants.Fonts.cellTextFont
        cell.detailTextLabel?.font = Constants.Fonts.cellTextFont
        cell.detailTextLabel?.textColor = Constants.Colors.detailTextColor

        if trackerType == .habit && indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.textLabel?.text = Constants.Texts.schedule
            if !selectedSchedule.isEmpty {
                let weekdayStrings = selectedSchedule.map { $0.shortTitle }
                cell.detailTextLabel?.text = weekdayStrings.joined(separator: ", ")
            }
        } else {
            if trackerType == .irregularEvent {
                cell.separatorInset = UIEdgeInsets(
                    top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            cell.textLabel?.text = Constants.Texts.category
            cell.detailTextLabel?.text = selectedCategory?.name
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if trackerType == .habit && indexPath.row == 1 {
            showScheduleViewController()
        } else {
            showCategoryViewController()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Sizes.tableViewCellHeight
    }
}

// MARK: - UITextFieldDelegate

extension TrackerFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Navigation

extension TrackerFormViewController {
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedWeekdays = selectedSchedule
        scheduleVC.onDone = { [weak self] selectedWeekdays in
            self?.selectedSchedule = selectedWeekdays
            self?.tableView.reloadData()
            self?.updateDoneButtonState()
        }
        scheduleVC.modalPresentationStyle = .pageSheet
        present(scheduleVC, animated: true, completion: nil)
    }

    private func showCategoryViewController() {
        let categoryVC = CategoryListViewController(
            viewModel: CategoryViewModel(), selectedCategory: selectedCategory)
        categoryVC.onDone = { [weak self] selectedCategory in
            self?.selectedCategory = selectedCategory
            self?.tableView.reloadData()
            self?.updateDoneButtonState()
        }
        categoryVC.modalPresentationStyle = .pageSheet
        present(categoryVC, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerFormViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    { section == 0 ? emojis.count : colorNames.count }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderReusableView.reuseIdentifier,
                for: indexPath) as? TrackerHeaderReusableView
        else {
            return UICollectionReusableView()
        }
        let title = indexPath.section == 0 ? Constants.Texts.emoji : Constants.Texts.color
        header.configure(with: title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {

        if indexPath.section == 0 {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath)
                    as? EmojiCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.row]
            cell.configure(with: emoji)
            cell.configureSelection(isSelected: selectedEmoji == emoji)
            return cell
        } else {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath)
                    as? ColorCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            let colorName = colorNames[indexPath.row]
            cell.configure(with: colorName)
            cell.configureSelection(isSelected: selectedColorName == colorName)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousSelectedIndexPath: IndexPath?
        if indexPath.section == 0 {
            if let previousEmoji = emojis.firstIndex(of: selectedEmoji) {
                previousSelectedIndexPath = IndexPath(row: previousEmoji, section: 0)
            } else {
                previousSelectedIndexPath = nil
            }
        } else {
            if let previousColor = colorNames.firstIndex(of: selectedColorName) {
                previousSelectedIndexPath = IndexPath(row: previousColor, section: 1)
            } else {
                previousSelectedIndexPath = nil
            }
        }

        if indexPath.section == 0 {
            selectedEmoji = emojis[indexPath.row]
        } else {
            selectedColorName = colorNames[indexPath.row]
        }

        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previous = previousSelectedIndexPath, previous != indexPath {
            indexPathsToReload.append(previous)
        }

        collectionView.performBatchUpdates(
            {
                collectionView.reloadItems(at: indexPathsToReload)
            }, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerFormViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath:
            IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 7
        let numberOfItemsPerRow: CGFloat = 6
        let width = (collectionView.frame.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat { 10 }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat { 10 }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets { UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
}

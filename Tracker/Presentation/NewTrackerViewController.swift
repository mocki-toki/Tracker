//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    // MARK: - Constants
    
    private enum Constants {
        enum Texts {
            static let enterTrackName = NSLocalizedString("EnterTrackName", comment: "Enter track name hint")
            static let cancel = NSLocalizedString("Cancel", comment: "Cancel button")
            static let create = NSLocalizedString("Create", comment: "Create button")
            static let newHabit = NSLocalizedString("NewHabit", comment: "Title for creating a new habit")
            static let newIrregularEvent = NSLocalizedString("NewIrregularEvent", comment: "Title for creating a new irregular event")
            static let schedule = NSLocalizedString("Schedule", comment: "Button for schedule section")
            static let category = NSLocalizedString("Category", comment: "Button for category selection")
            static let generalCategory = "Общее"
        }
        
        enum Sizes {
            static let cornerRadius: CGFloat = 16
            static let textFieldHeight: CGFloat = 75
            static let buttonHeight: CGFloat = 60
            static let tableViewCellHeight: CGFloat = 75
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
            static let cancelButtonBorder = UIColor.red
            static let createButtonBackground = UIColor.ypBlack
            static let createButtonText = UIColor.white
            static let detailTextColor = UIColor.ypGray
        }
        
        enum Fonts {
            static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            static let cellTextFont = UIFont.systemFont(ofSize: 17)
        }
    }
    
    // MARK: - Properties
    
    enum TrackerType {
        case habit
        case irregularEvent
    }
    
    private let trackerType: TrackerType
    private var selectedSchedule: Set<Weekday> = []
    
    var onTrackerCreated: ((Tracker) -> Void)?
    
    // MARK: - UI Components
    
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
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.Paddings.horizontalPadding, height: textField.frame.height))
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.Paddings.horizontalPadding, bottom: 0, right: Constants.Paddings.horizontalPadding)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.create, for: .normal)
        button.setTitleColor(Constants.Colors.createButtonText, for: .normal)
        button.backgroundColor = Constants.Colors.createButtonBackground
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initialization
    
    init(type: TrackerType) {
        self.trackerType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureForTrackerType()
        setupKeyboardDismissal()
    }

    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = Constants.Colors.background
        
        [titleLabel, nameTextField, tableView, cancelButton, createButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Paddings.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Paddings.textFieldTopPadding),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Paddings.horizontalPadding),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.Sizes.textFieldHeight),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Constants.Paddings.tableViewTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Paddings.horizontalPadding),
            tableView.heightAnchor.constraint(equalToConstant: trackerType == .habit ? Constants.Sizes.tableViewCellHeight * 2 : Constants.Sizes.tableViewCellHeight),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Paddings.buttonBottomPadding),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Paddings.buttonBottomPadding),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Paddings.horizontalPadding),
            createButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: Constants.Paddings.buttonSpacing)
        ])
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateCreateButtonState()
    }
    
    private func configureForTrackerType() {
        switch trackerType {
        case .habit:
            titleLabel.text = Constants.Texts.newHabit
        case .irregularEvent:
            titleLabel.text = Constants.Texts.newIrregularEvent
        }
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            emoji: "😀",
            color: .systemBlue,
            schedule: trackerType == .habit ? selectedSchedule : nil
        )
        
        dismiss(animated: true) { [weak self] in
            self?.onTrackerCreated?(newTracker)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        let isScheduleValid = trackerType == .irregularEvent || !selectedSchedule.isEmpty
        createButton.isEnabled = isNameValid && isScheduleValid
        createButton.backgroundColor = Constants.Colors.createButtonBackground
        createButton.layer.opacity = createButton.isEnabled ? 1 : 0.5
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension NewTrackerViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.textLabel?.text = Constants.Texts.schedule
            if !selectedSchedule.isEmpty {
                let weekdayStrings = selectedSchedule.map { $0.shortTitle }
                cell.detailTextLabel?.text = weekdayStrings.joined(separator: ", ")
            }
        } else {
            if trackerType == .irregularEvent {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            cell.textLabel?.text = Constants.Texts.category
            cell.detailTextLabel?.text = Constants.Texts.generalCategory
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

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Navigation

extension NewTrackerViewController {
    private func showScheduleViewController() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedWeekdays = selectedSchedule
        scheduleVC.onDone = { [weak self] selectedWeekdays in
            self?.selectedSchedule = selectedWeekdays
            self?.tableView.reloadData()
            self?.updateCreateButtonState()
        }
        scheduleVC.modalPresentationStyle = .pageSheet
        present(scheduleVC, animated: true, completion: nil)
    }
    
    private func showCategoryViewController() {
    }
}

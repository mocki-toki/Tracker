//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 04.09.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Texts {
        static let schedule = NSLocalizedString("Schedule", comment: "Title for schedule section")
        static let done = NSLocalizedString("Done", comment: "Button title for completing an action")
    }

    enum Sizes {
        static let cornerRadius: CGFloat = 16
        static let cellHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
    }

    enum Paddings {
        static let titleTopPadding: CGFloat = 20
        static let tableViewTopPadding: CGFloat = 20
        static let tableViewHorizontalPadding: CGFloat = 16
        static let tableViewBottomPadding: CGFloat = 20
        static let buttonBottomPadding: CGFloat = 16
        static let buttonHorizontalPadding: CGFloat = 20
        static let cellContentPadding: CGFloat = 16
    }

    enum Colors {
        static let background = UIColor.white
        static let buttonBackground = UIColor.black
        static let buttonText = UIColor.white
        static let cellBackground = UIColor.ypBackground
        static let cellText = UIColor.black
        static let cellDetailText = UIColor.ypGray
    }

    enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let cellFont = UIFont.systemFont(ofSize: 17)
    }
}

// MARK: - ScheduleViewController

final class ScheduleViewController: UIViewController {
    // MARK: - Properties

    var selectedWeekdays: Set<Weekday> = []
    var onDone: ((Set<Weekday>) -> Void)?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.schedule
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeekdayTableCell.self, forCellReuseIdentifier: WeekdayTableCell.identifier)
        tableView.layer.cornerRadius = Constants.Sizes.cornerRadius
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.Paddings.cellContentPadding, bottom: 0, right: Constants.Paddings.cellContentPadding)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.done, for: .normal)
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.backgroundColor = Constants.Colors.buttonBackground
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        onDone?(selectedWeekdays)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background

        [titleLabel, tableView, doneButton].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Paddings.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.Paddings.tableViewTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Paddings.tableViewHorizontalPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Paddings.tableViewHorizontalPadding),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -Constants.Paddings.tableViewBottomPadding),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Paddings.buttonBottomPadding),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Paddings.buttonHorizontalPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Paddings.buttonHorizontalPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight)
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeekdayTableCell.identifier, for: indexPath) as! WeekdayTableCell

        cell.backgroundColor = Constants.Colors.cellBackground
        cell.textLabel?.font = Constants.Fonts.cellFont
        cell.detailTextLabel?.font = Constants.Fonts.cellFont
        cell.detailTextLabel?.textColor = Constants.Colors.cellDetailText

        let weekday = Weekday.allCases[indexPath.row]
        cell.configure(with: weekday, isSelected: selectedWeekdays.contains(weekday))
        cell.onSwitchValueChanged = { [weak self] isOn in
            if isOn {
                self?.selectedWeekdays.insert(weekday)
            } else {
                self?.selectedWeekdays.remove(weekday)
            }
        }

        if indexPath.row == Weekday.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? WeekdayTableCell else { return }
        cell.selectionSwitch.setOn(!cell.selectionSwitch.isOn, animated: true)
        cell.selectionSwitch.sendActions(for: .valueChanged)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Sizes.cellHeight
    }
}

//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 04.09.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Properties

    var selectedWeekdays: Set<Weekday> = []
    var onDone: ((Set<Weekday>) -> Void)?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Schedule", comment: "Title for schedule section")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeekdayCell.self, forCellReuseIdentifier: "WeekdayCell")
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Done", comment: "Button title for completing an action"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        [titleLabel, tableView, doneButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        onDone?(selectedWeekdays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath) as! WeekdayCell
        
        cell.backgroundColor = .ypBackground
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypGray
        
        let weekday = Weekday.allCases[indexPath.row]
        cell.configure(with: weekday, isSelected: selectedWeekdays.contains(weekday))
        cell.onSwitchValueChanged = { [weak self] isOn in
            if isOn {
                self?.selectedWeekdays.insert(weekday)
            } else {
                self?.selectedWeekdays.remove(weekday)
            }
        }
        
        if indexPath.row == 7 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? WeekdayCell else { return }
        cell.selectionSwitch.setOn(!cell.selectionSwitch.isOn, animated: true)
        cell.selectionSwitch.sendActions(for: .valueChanged)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - WeekdayCell

final class WeekdayCell: UITableViewCell {
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    let selectionSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemBlue
        return switchControl
    }()

    var onSwitchValueChanged: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [weekdayLabel, selectionSwitch].forEach { contentView.addSubview($0) }

        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            weekdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weekdayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            selectionSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            selectionSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        selectionSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    func configure(with weekday: Weekday, isSelected: Bool) {
        weekdayLabel.text = weekday.fullTitle
        selectionSwitch.isOn = isSelected
    }

    @objc private func switchValueChanged() {
        onSwitchValueChanged?(selectionSwitch.isOn)
    }
}

//
//  WeekdayTableCell.swift
//  Tracker
//
//  Created by Simon Butenko on 03.12.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Paddings {
        static let cellContentPadding: CGFloat = 16
    }

    enum Colors {
        static let switchTint = UIColor.systemBlue
    }

    enum Fonts {
        static let cellFont = UIFont.systemFont(ofSize: 17)
    }
}

// MARK: - WeekdayTableCell

final class WeekdayTableCell: UITableViewCell {
    static let identifier = "WeekdayTableCell"
    
    // MARK: - UI Components

    private lazy var weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.cellFont
        return label
    }()

    let selectionSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = Constants.Colors.switchTint
        return switchControl
    }()

    // MARK: - Properties

    var onSwitchValueChanged: ((Bool) -> Void)?

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with weekday: Weekday, isSelected: Bool) {
        weekdayLabel.text = weekday.fullTitle
        selectionSwitch.isOn = isSelected
    }

    // MARK: - Actions

    @objc private func switchValueChanged() {
        onSwitchValueChanged?(selectionSwitch.isOn)
    }
}

extension WeekdayTableCell: UIConfigurable {
    func setupUI() {
        [weekdayLabel, selectionSwitch].forEach { contentView.addSubview($0) }

        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionSwitch.translatesAutoresizingMaskIntoConstraints = false

        selectionSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            weekdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Paddings.cellContentPadding),
            weekdayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            selectionSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Paddings.cellContentPadding),
            selectionSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

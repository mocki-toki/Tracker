//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        enum Texts {
            static let createTracker = NSLocalizedString("CreateTracker", comment: "Title for tracker creation screen")
            static let habit = NSLocalizedString("Habit", comment: "Label for habit type tracker")
            static let irregularEvent = NSLocalizedString("IrregularEvent", comment: "Label for irregular event type tracker")
        }

        enum Fonts {
            static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            static let buttonFont = UIFont.boldSystemFont(ofSize: 16)
        }

        enum Colors {
            static let background = UIColor.white
            static let buttonBackground = UIColor.black
            static let buttonText = UIColor.white
        }

        enum Sizes {
            static let titleTopPadding: CGFloat = 20
            static let buttonStackViewSidePadding: CGFloat = 20
            static let buttonHeight: CGFloat = 60
            static let buttonCornerRadius: CGFloat = 16
            static let buttonStackViewSpacing: CGFloat = 16
        }
    }

    // MARK: - Properties

    var onTypeSelected: ((TrackerType) -> Void)?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.createTracker
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.Sizes.buttonStackViewSpacing
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.habit, for: .normal)
        button.titleLabel?.font = Constants.Fonts.buttonFont
        button.backgroundColor = Constants.Colors.buttonBackground
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Sizes.buttonCornerRadius
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.irregularEvent, for: .normal)
        button.titleLabel?.font = Constants.Fonts.buttonFont
        button.backgroundColor = Constants.Colors.buttonBackground
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.Sizes.buttonCornerRadius
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func habitButtonTapped() {
        onTypeSelected?(.habit)
    }

    @objc private func irregularEventButtonTapped() {
        onTypeSelected?(.irregularEvent)
    }
}

extension TrackerTypeSelectionViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background

        [titleLabel, buttonStackView].forEach { view.addSubview($0) }

        [habitButton, irregularEventButton].forEach { buttonStackView.addArrangedSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Sizes.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Sizes.buttonStackViewSidePadding),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Sizes.buttonStackViewSidePadding),

            habitButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight),
            irregularEventButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.buttonHeight)
        ])
    }
}

//
//  CategoryFormViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 03.08.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Texts {
        static let createCategory = NSLocalizedString(
            "CreateCategory", comment: "Title for creating category")
        static let editCategory = NSLocalizedString(
            "EditCategory", comment: "Title for editing category")
        static let enterCategoryName = NSLocalizedString(
            "EnterCategoryName", comment: "Enter category name hint")
        static let done = NSLocalizedString(
            "Done", comment: "Button title for completing an action")
    }

    enum Sizes {
        static let cornerRadius: CGFloat = 16
        static let cellHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let textFieldHeight: CGFloat = 75
    }

    enum Paddings {
        static let titleTopPadding: CGFloat = 20
        static let buttonBottomPadding: CGFloat = 16
        static let cellContentPadding: CGFloat = 16
        static let textFieldTopPadding: CGFloat = 38
        static let horizontalPadding: CGFloat = 16
    }

    enum Colors {
        static let background = UIColor.white
        static let buttonBackground = UIColor.black
        static let buttonText = UIColor.white
        static let cellBackground = UIColor.ypBackground
        static let cellText = UIColor.black
        static let cellDetailText = UIColor.ypGray
        static let switchTint = UIColor.systemBlue
        static let textFieldBackground = UIColor.ypBackground
    }

    enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let cellFont = UIFont.systemFont(ofSize: 17)
    }
}

final class CategoryFormViewController: UIViewController {
    // MARK: - Properties

    private var editedCategory: TrackerCategory?
    var onTappedCreate: ((String) -> Void)?
    var onTappedEdit: ((String) -> Void)?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text =
            editedCategory == nil ? Constants.Texts.createCategory : Constants.Texts.editCategory
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Constants.Texts.enterCategoryName
        textField.backgroundColor = Constants.Colors.textFieldBackground
        textField.layer.cornerRadius = Constants.Sizes.cornerRadius
        textField.leftView = UIView(
            frame: CGRect(
                x: 0, y: 0, width: Constants.Paddings.horizontalPadding,
                height: textField.frame.height))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
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

    init(editedCategory: TrackerCategory?) {
        self.editedCategory = editedCategory
        super.init(nibName: nil, bundle: nil)

        if let category = editedCategory {
            self.nameTextField.text = category.name
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardDismissal()
        updateCreateButtonState()
    }

    // MARK: - UI Setup

    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        nameTextField.delegate = self
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        if editedCategory == nil {
            onTappedCreate?(nameTextField.text!)
        } else {
            onTappedEdit?(nameTextField.text!)
        }

        self.dismiss(animated: true, completion: nil)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }

    private func updateCreateButtonState() {
        let isNameValid = !(nameTextField.text?.isEmpty ?? true)
        doneButton.isEnabled = isNameValid
        doneButton.layer.opacity = doneButton.isEnabled ? 1 : 0.5
    }
}

extension CategoryFormViewController: UIConfigurable {
    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = .white

        [titleLabel, nameTextField, doneButton].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Constants.Paddings.textFieldTopPadding),
            nameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Paddings.horizontalPadding),
            nameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -Constants.Paddings.horizontalPadding
            ),
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.Sizes.textFieldHeight),

            doneButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension CategoryFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension CategoryFormViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch)
        -> Bool
    {
        return touch.view === self.view
    }
}

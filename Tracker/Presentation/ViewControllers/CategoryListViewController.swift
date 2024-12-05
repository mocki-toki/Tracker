//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 03.08.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Texts {
        static let cagegoriesIsEmptyPlaceholder = NSLocalizedString(
            "CategoriesIsEmptyPlaceholder", comment: "Placeholder text for empty category list")
        static let category = NSLocalizedString("Category", comment: "Title for category section")
        static let addCategory = NSLocalizedString(
            "AddCategory", comment: "Button title for adding category")
    }

    enum Sizes {
        static let cornerRadius: CGFloat = 16
        static let cellHeight: CGFloat = 75
        static let buttonHeight: CGFloat = 60
        static let placeholderImageSize: CGFloat = 80
        static let placeholderLabelTopPadding: CGFloat = 8
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
        static let background = UIColor.ypWhite
        static let buttonBackground = UIColor.ypBlack
        static let buttonText = UIColor.ypWhite
        static let cellBackground = UIColor.ypBackground
        static let cellText = UIColor.ypBlack
        static let cellDetailText = UIColor.ypGray
        static let switchTint = UIColor.ypBlue
        static let placeholderText = UIColor.ypBlack
    }

    enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let cellFont = UIFont.systemFont(ofSize: 17)
        static let placeholderFont = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

final class CategoryListViewController: UIViewController {
    // MARK: - Properties

    private var viewModel: CategoryViewModel
    private var selectedCategory: TrackerCategory?
    var onDone: ((TrackerCategory) -> Void)?

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.category
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        label.text = Constants.Texts.cagegoriesIsEmptyPlaceholder
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = Constants.Fonts.placeholderFont
        label.textColor = Constants.Colors.placeholderText
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.layer.cornerRadius = Constants.Sizes.cornerRadius
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: Constants.Paddings.cellContentPadding, bottom: 0,
            right: Constants.Paddings.cellContentPadding)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.Texts.addCategory, for: .normal)
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.backgroundColor = Constants.Colors.buttonBackground
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle Methods

    init(viewModel: CategoryViewModel, selectedCategory: TrackerCategory?) {
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        updatePlaceholderVisibility()
    }

    // MARK: - Bindings

    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updatePlaceholderVisibility()
            }
        }
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        let categoryVC = CategoryFormViewController(editedCategory: nil)
        categoryVC.onTappedCreate = { [weak self] categoryName in
            self?.viewModel.addCategory(name: categoryName)
        }

        categoryVC.modalPresentationStyle = .pageSheet
        present(categoryVC, animated: true, completion: nil)
    }

    private func updatePlaceholderVisibility() {
        placeholderView.isHidden = !viewModel.categories.isEmpty
    }

    // MARK: - Editing and Deleting Categories

    private func editCategory(_ category: TrackerCategory) {
        let editCategoryVC = CategoryFormViewController(editedCategory: category)
        editCategoryVC.onTappedEdit = { [weak self] updatedName in
            self?.viewModel.updateCategory(category: category, newName: updatedName)
        }
        editCategoryVC.modalPresentationStyle = .pageSheet
        present(editCategoryVC, animated: true, completion: nil)
    }

    private func deleteCategory(_ category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString(
                "DeleteCategoryMessage", comment: "Сообщение для алерта удаления категории"),
            preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(
            title: NSLocalizedString("Delete", comment: "Кнопка удаления"), style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteCategory(category: category)
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Кнопка отмены"), style: .cancel,
            handler: nil)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

extension CategoryListViewController: UIConfigurable {
    // MARK: - UI Setup

    func setupUI() {
        view.backgroundColor = .ypWhite

        [titleLabel, tableView, addButton, placeholderView].forEach { view.addSubview($0) }
        [placeholderImageView, placeholderLabel].forEach { placeholderView.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),

            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),

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

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CategoryTableViewCell.identifier, for: indexPath)
                as? CategoryTableViewCell
        else {
            return UITableViewCell()
        }

        cell.backgroundColor = Constants.Colors.cellBackground
        cell.textLabel?.font = Constants.Fonts.cellFont
        cell.detailTextLabel?.font = Constants.Fonts.cellFont
        cell.detailTextLabel?.textColor = Constants.Colors.cellDetailText

        let category = viewModel.categories[indexPath.row]
        cell.configure(with: category, isSelected: category == selectedCategory)

        cell.onMenuAction = { [weak self] action in
            switch action {
            case .edit:
                self?.editCategory(category)
            case .delete:
                self?.deleteCategory(category)
            }
        }

        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(
                top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = viewModel.categories[indexPath.row]

        self.onDone?(category)
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Sizes.cellHeight
    }
}

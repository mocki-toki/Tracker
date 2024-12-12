//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 05.12.2024.
//

import UIKit

// MARK: - FilterOption Enum

enum FilterOption: String, CaseIterable {
    case all = "filter_all"
    case today = "filter_today"
    case completed = "filter_completed"
    case incomplete = "filter_incomplete"
}

// MARK: - Constants

private enum Constants {
    enum Texts {
        static let title = NSLocalizedString("filters_title", comment: "Title for Filters screen")
    }

    enum Sizes {
        static let cornerRadius: CGFloat = 16
    }

    enum Paddings {
        static let tableViewTopPadding: CGFloat = 20
        static let tableViewHorizontalPadding: CGFloat = 16
    }

    enum Colors {
        static let background = UIColor.ypWhite
    }

    enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
}

final class FiltersViewController: UIViewController {
    // MARK: - Initialization

    init(selectedFilter: FilterOption) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Properties

    var onFilterSelected: ((FilterOption) -> Void)?
    private var selectedFilter: FilterOption = .all

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.title
        label.font = Constants.Fonts.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        tableView.reloadData()
    }
}

// MARK: - UIConfigurable

extension FiltersViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background
        [titleLabel, tableView].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Constants.Paddings.tableViewTopPadding),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Paddings.tableViewHorizontalPadding
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.Paddings.tableViewHorizontalPadding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterOption.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FilterTableViewCell.identifier, for: indexPath)
                as? FilterTableViewCell
        else {
            return UITableViewCell()
        }

        let filterOption = FilterOption.allCases[indexPath.row]
        let isSelected = filterOption == selectedFilter
        cell.configure(
            with: NSLocalizedString(filterOption.rawValue, comment: "Filter option"),
            isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = FilterOption.allCases[indexPath.row]
        selectedFilter = selectedOption
        tableView.reloadData()

        onFilterSelected?(selectedOption)
        dismiss(animated: true, completion: nil)
    }
}

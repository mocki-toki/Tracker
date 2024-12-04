//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Simon Butenko on 03.12.2024.
//

import UIKit

private enum Constants {
    enum Paddings {
        static let cellContentPadding: CGFloat = 16
    }

    enum Colors {
        static let checkboxTint = UIColor.systemBlue
    }

    enum Fonts {
        static let cellFont = UIFont.systemFont(ofSize: 17)
    }
}

final class CategoryTableViewCell: UITableViewCell {
    static let identifier = "CategoryTableViewCell"

    // MARK: - UI Components

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let selectionCheckbox: UIImageView = {
        let image = UIImageView(
            image: UIImage(systemName: "checkmark")!.withTintColor(Constants.Colors.checkboxTint))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        [nameLabel, selectionCheckbox].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            selectionCheckbox.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.Paddings.cellContentPadding),
            selectionCheckbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionCheckbox.widthAnchor.constraint(equalToConstant: 20),
            selectionCheckbox.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    // MARK: - Configuration

    func configure(with category: TrackerCategory, isSelected: Bool) {
        nameLabel.text = category.name
        selectionCheckbox.isHidden = !isSelected
    }
}

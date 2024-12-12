//
//  FilterTableViewCell.swift
//  Tracker
//
//  Created by Simon Butenko on 05.12.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Colors {
        static let cellText = UIColor.ypBlack
        static let checkmarkTint = UIColor.ypBlue
    }

    enum Fonts {
        static let cellFont = UIFont.systemFont(ofSize: 17)
    }
}

// MARK: - FilterTableViewCell

final class FilterTableViewCell: UITableViewCell {
    static let identifier = "FilterTableViewCell"

    private lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.cellFont
        label.textColor = Constants.Colors.cellText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = Constants.Colors.checkmarkTint
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

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

    func configure(with text: String, isSelected: Bool) {
        filterLabel.text = text
        checkmarkImageView.isHidden = !isSelected
    }
}

// MARK: - UIConfigurable

extension FilterTableViewCell: UIConfigurable {
    func setupUI() {
        contentView.addSubview(filterLabel)
        contentView.addSubview(checkmarkImageView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            filterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            filterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}

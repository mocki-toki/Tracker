//
//  CategoryHeaderView.swift
//  Tracker
//
//  Created by Simon Butenko on 10.10.2024.
//

import UIKit

final class CategoryHeaderView: UICollectionReusableView {
    // MARK: - Constants

    private enum Constants {
        static let titleFont = UIFont.systemFont(ofSize: 19, weight: .bold)
        static let leadingPadding: CGFloat = 28
        static let trailingPadding: CGFloat = 28
    }

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.titleFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    var text: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryHeaderView: UIConfigurable {
    func setupUI() {
        addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.leadingPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.trailingPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

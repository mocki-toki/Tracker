//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Simon Butenko on 08.11.2024.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "ColorCollectionViewCell"

    private lazy var colorImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with color: UIColor) {
        colorImageView.backgroundColor = color
    }

    func configureSelection(isSelected: Bool) {
        colorBackgroundView.layer.borderWidth = isSelected ? 3 : 0
        colorBackgroundView.layer.borderColor = colorImageView.backgroundColor?.cgColor.copy(
            alpha: 0.3)
    }
}

extension ColorCollectionViewCell: UIConfigurable {
    func setupUI() {
        contentView.addSubview(colorBackgroundView)
        colorBackgroundView.addSubview(colorImageView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            colorBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            colorImageView.topAnchor.constraint(
                equalTo: colorBackgroundView.topAnchor, constant: 6),
            colorImageView.leadingAnchor.constraint(
                equalTo: colorBackgroundView.leadingAnchor, constant: 6),
            colorImageView.trailingAnchor.constraint(
                equalTo: colorBackgroundView.trailingAnchor, constant: -6),
            colorImageView.bottomAnchor.constraint(
                equalTo: colorBackgroundView.bottomAnchor, constant: -6),
        ])
    }
}

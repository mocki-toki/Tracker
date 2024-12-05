//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Simon Butenko on 08.11.2024.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "EmojiCollectionViewCell"

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var backgroundContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
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

    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }

    func configureSelection(isSelected: Bool) {
        backgroundContainer.backgroundColor = isSelected ? .ypLightGray : .clear
    }
}

extension EmojiCollectionViewCell: UIConfigurable {
    func setupUI() {
        contentView.addSubview(backgroundContainer)
        contentView.addSubview(emojiLabel)
        backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            emojiLabel.centerXAnchor.constraint(equalTo: backgroundContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: backgroundContainer.centerYAnchor),
        ])
    }
}

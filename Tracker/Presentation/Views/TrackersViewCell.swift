//
//  TrackersViewCell.swift
//  Tracker
//
//  Created by Simon Butenko on 04.09.2024.
//

import UIKit

final class TrackersViewCell: UICollectionViewCell {
    // MARK: - Constants

    private enum Constants {
        enum Sizes {
            static let cornerRadius: CGFloat = 16
            static let emojiLabelCornerRadius: CGFloat = 12
            static let cardViewHeight: CGFloat = 90
            static let emojiLabelSize: CGFloat = 24
            static let plusButtonSize: CGFloat = 34
            static let plusButtonCornerRadius: CGFloat = 17
        }

        enum Fonts {
            static let emojiFont = UIFont.systemFont(ofSize: 14)
            static let nameFont = UIFont.systemFont(ofSize: 12, weight: .medium)
            static let daysCountFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        }

        enum Colors {
            static let emojiBackground = UIColor.ypWhite.withAlphaComponent(0.3)
            static let nameText = UIColor.ypWhite
            static let daysCountText = UIColor.ypBlack
            static let plusButtonTint = UIColor.ypWhite
            static let plusButtonBorder = UIColor.ypWhite
        }

        enum Paddings {
            static let cardViewPadding: CGFloat = 12
            static let nameLabelTopPadding: CGFloat = 8
            static let daysCountTopPadding: CGFloat = 16
            static let daysCountBottomPadding: CGFloat = 24
        }

        static let reuseIdentifier = "TrackerCell"
    }

    // MARK: - Properties

    static let reuseIdentifier = Constants.reuseIdentifier

    var onPlusButtonTap: (() -> Void)?
    var onMenuAction: ((_ action: MenuAction) -> Void)?
    var isPinned: Bool = false

    enum MenuAction {
        case unpin
        case pin
        case edit
        case delete
    }

    // MARK: - UI Components

    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Sizes.cornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.emojiFont
        label.textAlignment = .center
        label.backgroundColor = Constants.Colors.emojiBackground
        label.layer.cornerRadius = Constants.Sizes.emojiLabelCornerRadius
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.nameFont
        label.textColor = Constants.Colors.nameText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.daysCountFont
        label.textColor = Constants.Colors.daysCountText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.frame.size = CGSize(width: 8, height: 8)
        button.tintColor = Constants.Colors.plusButtonTint
        button.backgroundColor = .clear
        button.layer.cornerRadius = Constants.Sizes.plusButtonCornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = Constants.Colors.plusButtonBorder.cgColor
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupContextMenu()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysCountLabel.text = "\(pluralizeDays(completedDays))"
        isPinned = tracker.isPinned

        let color = UIColor(named: tracker.colorName) ?? UIColor.ypGray
        cardView.backgroundColor = color

        if isCompleted {
            plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            plusButton.backgroundColor = color.withAlphaComponent(0.3)
            plusButton.tintColor = .ypWhite
            plusButton.layer.borderWidth = 0
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.backgroundColor = color
            plusButton.tintColor = .ypWhite
            plusButton.layer.borderWidth = 1
            plusButton.layer.borderColor = UIColor.ypWhite.cgColor
        }
    }

    // MARK: - Actions

    @objc private func plusButtonTapped() {
        onPlusButtonTap?()
    }

    // MARK: - Context Menu

    private func setupContextMenu() {
        let interaction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(interaction)
    }

    // MARK: - Helpers

    private func pluralizeDays(_ count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("Days", comment: "Number of days"), count)
    }
}

extension TrackersViewCell: UIConfigurable {
    func setupUI() {
        [cardView, daysCountLabel, plusButton].forEach { contentView.addSubview($0) }
        [emojiLabel, nameLabel].forEach { cardView.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: Constants.Sizes.cardViewHeight),

            emojiLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor, constant: Constants.Paddings.cardViewPadding),
            emojiLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor, constant: Constants.Paddings.cardViewPadding),
            emojiLabel.widthAnchor.constraint(equalToConstant: Constants.Sizes.emojiLabelSize),
            emojiLabel.heightAnchor.constraint(equalToConstant: Constants.Sizes.emojiLabelSize),

            nameLabel.topAnchor.constraint(
                equalTo: emojiLabel.bottomAnchor, constant: Constants.Paddings.nameLabelTopPadding),
            nameLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor, constant: Constants.Paddings.cardViewPadding),
            nameLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor, constant: -Constants.Paddings.cardViewPadding),
            nameLabel.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor, constant: -Constants.Paddings.cardViewPadding),

            daysCountLabel.topAnchor.constraint(
                equalTo: cardView.bottomAnchor, constant: Constants.Paddings.daysCountTopPadding),
            daysCountLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: Constants.Paddings.cardViewPadding),
            daysCountLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.Paddings.daysCountBottomPadding),

            plusButton.centerYAnchor.constraint(equalTo: daysCountLabel.centerYAnchor),
            plusButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -Constants.Paddings.cardViewPadding),
            plusButton.widthAnchor.constraint(equalToConstant: Constants.Sizes.plusButtonSize),
            plusButton.heightAnchor.constraint(equalToConstant: Constants.Sizes.plusButtonSize),
        ])
    }
}

// MARK: - UIContextMenuInteractionDelegate

extension TrackersViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let unpinAction = UIAction(title: "Открепить") { [weak self] _ in
                self?.onMenuAction?(.unpin)
            }

            let pinAction = UIAction(title: "Закрепить") { [weak self] _ in
                self?.onMenuAction?(.pin)
            }

            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.onMenuAction?(.edit)
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) {
                [weak self] _ in
                self?.onMenuAction?(.delete)
            }

            let pinOrUnpinAction = self.isPinned ? unpinAction : pinAction
            return UIMenu(children: [pinOrUnpinAction, editAction, deleteAction])
        }
    }
}

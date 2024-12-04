//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 04.08.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        static let descriptionFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    enum Colors {
        static let titleText = UIColor.ypBlack
    }
}

// MARK: - OnboardingPageViewController

final class OnboardingPageViewController: UIViewController {
    // MARK: - Properties

    private let imageName: String
    private let titleText: String

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Fonts.titleFont
        label.textColor = Constants.Colors.titleText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer

    init(imageName: String, titleText: String) {
        self.imageName = imageName
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)

        imageView.image = UIImage(named: imageName)
        titleLabel.text = titleText
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -270),
        ])
    }
}

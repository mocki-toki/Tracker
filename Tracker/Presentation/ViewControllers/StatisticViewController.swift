//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 05.12.2024.
//

import UIKit

final class CounterView: UIView {

    // MARK: - UI Components

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor.ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()

    // MARK: - Initialization

    init(value: Int, title: String) {
        super.init(frame: .zero)
        setupView()
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func update(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }

    // MARK: - Setup Methods

    private func setupView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 123 / 255, blue: 250 / 255, alpha: 1).cgColor,
            UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1).cgColor,
            UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 16

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        gradientLayer.mask = shapeLayer

        layer.addSublayer(gradientLayer)

        backgroundColor = .clear
        layer.cornerRadius = 16
        clipsToBounds = true

        [valueLabel, titleLabel].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer,
            let shapeLayer = gradientLayer.mask as? CAShapeLayer
        {
            gradientLayer.frame = bounds
            shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        }
    }
}

final class StatisticViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        enum Texts {
            static let title = NSLocalizedString(
                "Statistic_Title", comment: "Title for the StatisticViewController")
            static let noDataText = NSLocalizedString(
                "Statistic_NoDataText", comment: "Text displayed when there is no data to analyze")
            static let trackersCount = NSLocalizedString(
                "Statistic_TrackersCount", comment: "Label for total trackers count")
            static let trackersCompleted = NSLocalizedString(
                "Statistic_TrackersCompleted", comment: "Label for completed trackers count")
        }

        enum Fonts {
            static let titleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
            static let statFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        }

        enum Colors {
            static let background = UIColor.ypWhite
            static let textColor = UIColor.ypBlack
        }

        enum Sizes {
            static let titleTopPadding: CGFloat = 44
            static let titleLeadingPadding: CGFloat = 16
            static let statsTopPadding: CGFloat = 77
            static let statLabelLeadingPadding: CGFloat = 16
            static let placeholderImageSize: CGFloat = 80
            static let placeholderLabelTopPadding: CGFloat = 8
        }
    }

    // MARK: - Properties

    private let dataProvider = DataProvider()
    private var trackersCompleted: Int = 0
    private var trackersCount: Int = 0

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.title
        label.font = Constants.Fonts.titleFont
        label.textColor = Constants.Colors.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.ypEmptyStatisticsPlaceholder)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Texts.noDataText
        label.textAlignment = .center
        label.font = Constants.Fonts.statFont
        label.textColor = Constants.Colors.textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        stackView.spacing = 12
        return stackView
    }()

    private func createCounterView(title: String, value: Int) -> CounterView {
        let counter = CounterView(value: value, title: title)
        counter.translatesAutoresizingMaskIntoConstraints = false
        return counter
    }

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
        self.dataProvider.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.background

        view.addSubview(titleLabel)
        view.addSubview(placeholderView)
        view.addSubview(statsStackView)

        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)

        statsStackView.addArrangedSubview(
            createCounterView(title: Constants.Texts.trackersCompleted, value: trackersCompleted))
        statsStackView.addArrangedSubview(
            createCounterView(title: Constants.Texts.trackersCount, value: trackersCount))
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Constants.Sizes.titleTopPadding),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: Constants.Sizes.titleLeadingPadding),

            statsStackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: Constants.Sizes.statsTopPadding),
            statsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),

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

    // MARK: - Data Loading

    private func loadStatistics() {
        trackersCompleted = dataProvider.getAllRecords().count
        trackersCount = dataProvider.getAllTrackersWithCategories().map { $0.trackers.count }
            .reduce(0, +)

        updateUI()
    }

    private func updateUI() {
        if trackersCount == 0 {
            placeholderView.isHidden = false
            statsStackView.isHidden = true
        } else {
            placeholderView.isHidden = true
            statsStackView.isHidden = false

            if let trackersCompletedCounter = statsStackView.arrangedSubviews[0] as? CounterView {
                trackersCompletedCounter.update(
                    value: trackersCompleted, title: Constants.Texts.trackersCompleted)
            }
            if let trackersCountCounter = statsStackView.arrangedSubviews[1] as? CounterView {
                trackersCountCounter.update(
                    value: trackersCount, title: Constants.Texts.trackersCount)
            }
        }
    }
}

// MARK: - DataProviderDelegate

extension StatisticViewController: DataProviderDelegate {
    func dataDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.loadStatistics()
        }
    }
}

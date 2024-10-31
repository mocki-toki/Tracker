//
//  MainViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Constants

    private enum Constants {
        enum TabBar {
            static let trackersTitle = NSLocalizedString("Trackers", comment: "Trackers tab bar item")
            static let statisticsTitle = NSLocalizedString("Statistics", comment: "Statistics tab bar item")
            static let trackersTag = 0
            static let statisticsTag = 1
        }

        enum Layout {
            static let tabBarLeadingPadding: CGFloat = 0
            static let tabBarTrailingPadding: CGFloat = 0
        }

        enum Colors {
            static let tabBarTint = UIColor.ypBlue
            static let background = UIColor.systemBackground
            static let statisticsBackground = UIColor.white
        }
    }

    // MARK: - UI Components

    private lazy var tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.tintColor = Constants.Colors.tabBarTint
        tabBar.items = [
            UITabBarItem(title: Constants.TabBar.trackersTitle, image: .ypTrackers, tag: Constants.TabBar.trackersTag),
            UITabBarItem(title: Constants.TabBar.statisticsTitle, image: .ypStatistics, tag: Constants.TabBar.statisticsTag)
        ]
        tabBar.selectedItem = tabBar.items?.first
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - View Controllers

    private lazy var trackersViewController = TrackersViewController()
    private lazy var statisticsViewController: UIViewController = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = Constants.Colors.statisticsBackground
        let label = UILabel()
        label.text = Constants.TabBar.statisticsTitle
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        return viewController
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        switchToTab(at: 0)
    }

    // MARK: - Tab Switching

    private func switchToTab(at index: Int) {
        guard let viewController = viewControllerForTab(at: index) else { return }

        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    private func viewControllerForTab(at index: Int) -> UIViewController? {
        switch index {
        case Constants.TabBar.trackersTag: return trackersViewController
        case Constants.TabBar.statisticsTag: return statisticsViewController
        default: return nil
        }
    }
}

// MARK: - UIConfigurable

extension MainViewController: UIConfigurable {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background
        [containerView, tabBar].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.tabBarLeadingPadding),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.tabBarTrailingPadding),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITabBarDelegate

extension MainViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switchToTab(at: item.tag)
    }
}

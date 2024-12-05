//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 04.08.2024.
//

import UIKit

// MARK: - Constants

private enum Constants {
    enum Sizes {
        static let cornerRadius: CGFloat = 16
    }

    enum Colors {
        static let buttonBackground = UIColor.ypBlack
        static let buttonText = UIColor.ypWhite
        static let pageIndicator = UIColor.ypLightGray
        static let pageIndicatorSelected = UIColor.ypBlack
    }
}

// MARK: - OnboardingViewController

final class OnboardingViewController: UIPageViewController {
    // MARK: - Initializers

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Properties

    private let pages: [UIViewController] = [
        OnboardingPageViewController(
            imageName: "Onboarding Background 1",
            titleText: "Отслеживайте только то, что хотите"
        ),
        OnboardingPageViewController(
            imageName: "Onboarding Background 2",
            titleText: "Даже если это не литры воды и йога"
        ),
    ]

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(Constants.Colors.buttonText, for: .normal)
        button.backgroundColor = Constants.Colors.buttonBackground
        button.layer.cornerRadius = Constants.Sizes.cornerRadius
        button.addTarget(
            self, action: #selector(skipOnboarding), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.numberOfPages = 2
        pageControl.currentPageIndicatorTintColor = Constants.Colors.pageIndicatorSelected
        pageControl.pageIndicatorTintColor = Constants.Colors.pageIndicator
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        setupUI()
        setupConstraints()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(skipButton)
        view.addSubview(pageControl)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.heightAnchor.constraint(equalToConstant: 50),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    @objc private func skipOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        guard let scene = view.window?.windowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else {
            return
        }

        window.rootViewController = MainViewController()
        window.makeKeyAndVisible()
    }
}
// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentVC = pageViewController.viewControllers?.first,
            let index = pages.firstIndex(of: currentVC)
        {
            pageControl.currentPage = index
        }
    }
}

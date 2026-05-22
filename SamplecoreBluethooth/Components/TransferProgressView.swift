//
//  TransferProgressView.swift
//  SamplecoreBluethooth
//
//  Create by Esakki IOS 20 may 2026
//

import UIKit

final class TransferProgressView: UIView {

    private let iconView    = UIImageView()
    private let nameLabel   = UILabel()
    private let pctLabel    = UILabel()
    private let progressBar = UIProgressView()
    private let subtitleLbl = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconView.image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg)
        iconView.tintColor = .nsAccent
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text      = "Preparing..."
        nameLabel.font      = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .nsTextPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        pctLabel.text          = "0%"
        pctLabel.font          = UIFont.monospacedSystemFont(ofSize: 14, weight: .bold)
        pctLabel.textColor     = .nsAccent
        pctLabel.textAlignment = .right
        pctLabel.setContentHuggingPriority(.required, for: .horizontal)
        pctLabel.translatesAutoresizingMaskIntoConstraints = false

        progressBar.progressTintColor = .nsAccent
        progressBar.trackTintColor    = UIColor(white: 1, alpha: 0.10)
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds     = true
        progressBar.setProgress(0, animated: false)
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        subtitleLbl.text      = "Transfer in progress"
        subtitleLbl.font      = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLbl.textColor = .nsTextTer
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(pctLabel)
        addSubview(progressBar)
        addSubview(subtitleLbl)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: pctLabel.leadingAnchor, constant: -8),

            pctLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            pctLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            progressBar.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 8),

            subtitleLbl.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 6),
            subtitleLbl.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLbl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func update(fileName: String, progress: Float, isSending: Bool) {
        nameLabel.text = fileName.isEmpty ? "Preparing..." : fileName
        pctLabel.text  = "\(Int(progress * 100))%"
        progressBar.setProgress(progress, animated: true)
        subtitleLbl.text = isSending ? "Sending file..." : "Receiving file..."

        let cfg      = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let iconName = isSending ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
        iconView.image = UIImage(systemName: iconName, withConfiguration: cfg)

        if progress >= 1.0 {
            progressBar.progressTintColor = .nsGreen
            iconView.tintColor            = .nsGreen
            pctLabel.textColor            = .nsGreen
            subtitleLbl.text              = isSending ? "Sent successfully ✓" : "Received ✓"
        } else {
            progressBar.progressTintColor = .nsAccent
            iconView.tintColor            = .nsAccent
            pctLabel.textColor            = .nsAccent
        }
    }
}

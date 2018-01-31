import UIKit

protocol ObjectViewDataSource: class {
    func components(in objectView: ObjectView) -> [[Component]]
    func customComponentView(for component: Component, in objectView: ObjectView) -> UIView?
}

protocol ObjectViewDelegate: class {
    // PhoneNumberComponentViewDelegate
    func objectView(_ objectView: ObjectView, didTapShowPhoneNumberFor component: PhoneNumberComponent)
    func objectView(_ objectView: ObjectView, didTapPhoneNumberFor component: PhoneNumberComponent)
    func objectView(_ objectView: ObjectView, canShowPhoneNumberFor component: PhoneNumberComponent) -> Bool

    // MessageButtonComponentViewDelegate
    func objectView(_ objectView: ObjectView, didTapSendMessageFor component: MessageButtonComponent)

    // IconButtonComponentViewDelegate
    func objectView(_ objectView: ObjectView, didTapButtonFor component: IconButtonComponent)

    // CollapsableDescriptionComponentViewDelegate
    func objectView(_ objectView: ObjectView, didTapExpandDescriptionFor component: CollapsableDescriptionComponent)
    func objectView(_ objectView: ObjectView, didTapHideDescriptionFor component: CollapsableDescriptionComponent)
}

class ObjectView: UIView {
    weak var dataSource: ObjectViewDataSource?
    weak var delegate: ObjectViewDelegate?

    private let animationDuration = 0.4

    lazy var scrollView: UIScrollView = {
        let view =  UIScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        scrollView.addSubview(contentView)
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func reloadData() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }

        guard let dataSource = dataSource else {
            return
        }

        let components = dataSource.components(in: self)
        var previousStackView: UIStackView?

        for (rowIndex, componentRow) in components.enumerated() {
            let componentStackView = setupStackView()

            for component in componentRow {
                if let componentView = viewComponent(for: component, in: self) {
                    componentStackView.addArrangedSubview(componentView)
                }
            }

            if componentStackView.arrangedSubviews.count > 0 {
                contentView.addSubview(componentStackView)

                NSLayoutConstraint.activate([
                    componentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .mediumLargeSpacing),
                    componentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.mediumLargeSpacing),
                ])

                if components.count == 1 {
                    NSLayoutConstraint.activate([
                        componentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                        componentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    ])
                } else {
                    switch rowIndex {
                    case 0:
                        NSLayoutConstraint.activate([
                            componentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                            ])
                    case components.count-1:
                        guard let previousStackView = previousStackView else {
                            fatalError()
                        }
                        NSLayoutConstraint.activate([
                            componentStackView.topAnchor.constraint(equalTo: previousStackView.bottomAnchor, constant: .mediumLargeSpacing),
                            componentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.mediumSpacing),
                            ])
                    default:
                        guard let previousStackView = previousStackView else {
                            fatalError()
                        }
                        NSLayoutConstraint.activate([
                            componentStackView.topAnchor.constraint(equalTo: previousStackView.bottomAnchor, constant: .mediumLargeSpacing),
                            ])
                    }
                    previousStackView = componentStackView
                }
            }
        }
    }

    func viewComponent(for component: Component, in objectView: ObjectView) -> UIView? {
        switch component.self {
        case is MessageButtonComponent:
            let listComponentView = MessageButtonComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.delegate = objectView
            listComponentView.component = component as? MessageButtonComponent
            return listComponentView
        case is PhoneNumberComponent:
            let listComponentView = PhoneNumberComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.delegate = objectView
            listComponentView.component = component as? PhoneNumberComponent
            return listComponentView
        case is IconButtonComponent:
            let listComponentView = IconButtonComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.delegate = objectView
            listComponentView.component = component as? IconButtonComponent
            return listComponentView
        case is CollapsableDescriptionComponent:
            let listComponentView = CollapsableDescriptionComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.delegate = objectView
            listComponentView.component = component as? CollapsableDescriptionComponent
            return listComponentView
        case is PriceComponent:
            let listComponentView = PriceComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.component = component as? PriceComponent
            return listComponentView
        case is TableComponent:
            let listComponentView = TableComponentView()
            listComponentView.translatesAutoresizingMaskIntoConstraints = false
            listComponentView.component = component as? TableComponent
            return listComponentView
        default: return nil
        }
    }

    func setupStackView() -> UIStackView {
        let stackView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.distribution = .fillProportionally
            view.spacing = .mediumSpacing
            return view
        }()
        return stackView
    }
}

extension ObjectView: LinkComponentViewDelegate {
    func linkComponentView(_ linkComponentView: LinkComponentView, didSelectComponent component: Component) {
//        delegate?.objectView(self, didSelectComponent: component)
    }
}

// MARK: - MessageButtonComponentViewDelegate

extension ObjectView: MessageComponentViewDelegate {
    func messageComponentView(_ messageComponentView: MessageButtonComponentView, didTapSendMessageFor component: MessageButtonComponent) {
        delegate?.objectView(self, didTapSendMessageFor: component)
    }
}

// MARK: - PhoneNumberComponentViewDelegate

extension ObjectView: PhoneNumberComponentViewDelegate {
    func phoneNumberComponentView(_ phoneNumberComponentView: PhoneNumberComponentView, didTapShowPhoneNumberFor component: PhoneNumberComponent) {
        delegate?.objectView(self, didTapShowPhoneNumberFor: component)
    }

    func phoneNumberComponentView(_ phoneNumberComponentView: PhoneNumberComponentView, didTapPhoneNumberFor component: PhoneNumberComponent) {
        delegate?.objectView(self, didTapPhoneNumberFor: component)
    }

    func phoneNumberComponentView(_ phoneNumberComponentView: PhoneNumberComponentView, canShowPhoneNumberFor component: PhoneNumberComponent) -> Bool {
        return delegate?.objectView(self, canShowPhoneNumberFor: component) ?? false
    }
}

// MARK: - IconButtonComponentViewDelegate

extension ObjectView: IconButtonComponentViewDelegate {
    func iconButtonComponentView(_ adressComponentView: IconButtonComponentView, didTapButtonFor component: IconButtonComponent) {
        delegate?.objectView(self, didTapButtonFor: component)
    }
}
extension ObjectView: SafePayComponentViewDelegate {
    func safePayComponentView(_ safePayComponentView: SafePayComponentView, didSelectComponent component: Component) {
//        delegate?.objectView(self, didSelectComponent: component)
    }
}
extension ObjectView: LoanPriceComponentViewDelegate {
    func loanPriceComponentView(_ loanPriceComponentView: LoanPriceComponentView, didSelectComponent component: Component) {
//        delegate?.objectView(self, didSelectComponent: component)
    }
}
extension ObjectView: AdReporterComponentViewDelegate {
    func adReporterComponentView(_ adReporterComponentView: AdReporterComponentView, didSelectComponent component: Component) {
//        delegate?.objectView(self, didSelectComponent: component)
    }
}

// MARK: - CollapsableDescriptionComponentViewDelegate

extension ObjectView: CollapsableDescriptionComponentViewDelegate {
    func collapsableDescriptionComponentView(_ collapsableDescriptionComponentView: CollapsableDescriptionComponentView, didTapExpandDescriptionFor component: CollapsableDescriptionComponent) {
        UIView.animate(withDuration: animationDuration, animations: {
            collapsableDescriptionComponentView.layoutIfNeeded()
            collapsableDescriptionComponentView.setButtonShowing(showing: false)
            self.layoutIfNeeded()
        }) { (finished) in
            self.delegate?.objectView(self, didTapExpandDescriptionFor: component)
            collapsableDescriptionComponentView.updateButtonTitle()

            UIView.animate(withDuration: self.animationDuration, animations: {
                collapsableDescriptionComponentView.setButtonShowing(showing: true)
            })
        }
    }

    func collapsableDescriptionComponentView(_ collapsableDescriptionComponentView: CollapsableDescriptionComponentView, didTapHideDescriptionFor component: CollapsableDescriptionComponent) {
        UIView.animate(withDuration: animationDuration, animations: {
            collapsableDescriptionComponentView.layoutIfNeeded()
            collapsableDescriptionComponentView.setButtonShowing(showing: false)
            self.layoutIfNeeded()
        }) { (finished) in
            self.delegate?.objectView(self, didTapHideDescriptionFor: component)
            collapsableDescriptionComponentView.updateButtonTitle()

            UIView.animate(withDuration: self.animationDuration, animations: {
                collapsableDescriptionComponentView.setButtonShowing(showing: true)
            })
        }
    }
}

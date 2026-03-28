//
//  RateDialogVC.swift
//  Video Player
//
//  Created by Did on 17/12/25.
//

import UIKit
import StoreKit

public class RateDialogVC: UIViewController, TagListViewDelegate {

    @IBOutlet weak var cosmosViewFull: CosmosView!
    @IBOutlet private weak var feedbackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var feedbackTextView: FeedbackTextView!
    var feedbackOptions:  [String] = []
    var isneverShow: Bool = false
    
    var titleSTR : String?
    var subtitleSTR : String?
    
    var onDismiss: (() -> Void)?
//    var selectedTags: [String] = []
    var selectedTags = Set<String>()
    
    var Comonrating: Double = 5.0
    @IBOutlet var btn_notNow: UIButton!
    @IBOutlet var btn_neverShow: UIButton!
    @IBOutlet var btn_submit: UIButton!
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var lbl_subtitle: UILabel!

    public override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            onDismiss?()
        }
    
    public init() {
        super.init(nibName: "RateDialogVC", bundle: .module)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    public override func viewDidLoad() {
        super.viewDidLoad()

        cosmosViewFull.didTouchCosmos = didTouchCosmos
        cosmosViewFull.rating = 4.0
        cosmosViewFull.didFinishTouchingCosmos = didFinishTouchingCosmos

        tagListView.textFont = .systemFont(ofSize: 12.0)// REGULARFont(size: 12.0)
        tagListView.tagViewHeight = 36
        tagListView.delegate = self
        for i in feedbackOptions{
            tagListView.addTag(i)
        }
        
        if isneverShow{
            btn_neverShow.isHidden = false
        }else{
            btn_neverShow.isHidden = true
        }
        
        btn_neverShow.setTitle("Don’t Ask Again", for: .normal)
        btn_notNow.setTitle("Maybe Later", for: .normal)
        btn_submit.setTitle("Rate Now", for: .normal)

        lbl_title.text = titleSTR
        lbl_subtitle.text = subtitleSTR
        
        lbl_title.font = .boldSystemFont(ofSize: 22.0)// BOLDFont(size: 22.0)
        lbl_subtitle.font = .systemFont(ofSize: 18.0) //REGULARFont(size: 18.0)
        
        feedbackHeightConstraint.constant = 0
        feedbackTextView.placeholder = "Tell us more about the issue..."
        // Do any additional setup after loading the view.
    }

    @IBAction func submitClick(){
        print("\(cosmosViewFull.rating)")        
        
        RatingTrigger.shared.neverShowAgain()

                if Comonrating >= 4 {
//                    log_Event(name: "rating_submit_4")
                    dismiss(animated: true){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            SKStoreReviewController.requestReview()
                        }
                    }
                }else{
//                    log_Event(name: "rating_submit_1")                    
                    dismiss(animated: true){
                        RatingTrigger.shared.delegate?.ratingPopupDidSubmit(
                            rating: Int(self.Comonrating),
                            selectedTags: Array(self.selectedTags),
                            feedbackText: self.feedbackTextView.text ?? ""
                                )
                    }
                }
    }
    
    @IBAction func neverShowClick(){
        RatingTrigger.shared.neverShowAgain()
        dismiss(animated: true)
    }
    
    @IBAction func notNowClick(){
//        log_Event(name: "rating_not_now_click")
        RatingTrigger.shared.incrementCancel()
        dismiss(animated: true)
    }
    private func didTouchCosmos(_ rating: Double) {
        print("Touch: \(rating)")
    }
    
    private func didFinishTouchingCosmos(_ rating: Double) {
        print("Ended: \(rating)")
        Comonrating = rating
        if rating <= 3 {
            UIView.animate(withDuration: 0.3) { self.feedbackHeightConstraint.constant = 0 }
        } else {
            UIView.animate(withDuration: 0.2) { self.feedbackHeightConstraint.constant = 0 } completion: { _ in
            }
        }
    }
    
    // MARK: TagListViewDelegate
    public func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
        
        if selectedTags.contains(title) {
               selectedTags.remove(title)
           } else {
               selectedTags.insert(title)
           }
        
//        selectedTags.append(title)
    }
    
    public func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
//        selectedTags.remove(title)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.feedbackTextView.endEditing(true)
    }

    
}




final class FeedbackTextView: UITextView {

    private let placeholderLabel = UILabel()

    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            updatePlaceholderVisibility()
        }
    }

    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = font ?? .systemFont(ofSize: 14)

        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification),
            name: UITextView.textDidChangeNotification,
            object: self
        )

        updatePlaceholderVisibility()
    }

    @objc private func textDidChangeNotification() {
        updatePlaceholderVisibility()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

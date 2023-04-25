//
//  TutorialViewController.swift
//  JobDeal
//
//  Created by Nikola Majstorovic on 24.7.22..
//  Copyright © 2022 Qwertify. All rights reserved.
//

import UIKit
import TransitionButton

class TutorialViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnNext: TransitionButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ivBackgroundImage: UIImageView!
    
    
    private var tutorialPage: Int = 0;
    
    var slides:[TutorialSlideNew] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func setupUI() {
        self.view.addGradientToBackground()
        
        self.btnNext.setupForTransitionLayoutTypeBlack()
        self.btnClose.setTitle("", for: .normal)
        self.btnClose.contentVerticalAlignment = .fill
        self.btnClose.contentHorizontalAlignment = .fill
        self.btnClose.imageEdgeInsets = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        self.btnClose.alpha = 0.7
        
        self.ivBackgroundImage.alpha = 0.2
    }
    
    override func setupStrings() {
        self.btnNext.setupTitleForKey(key: "next", uppercased: true)
    }
    
    @IBAction func nextTutorialAction(_ sender: UIButton) {
        if(tutorialPage == 3){
            navigationController?.popViewController(animated: true)
            return
        }
        
        tutorialPage += 1
        scrollToPage(page: tutorialPage)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollToPage(page: Int) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        /*
         *
         */
        setupSlideScrollView(slides: slides)
    }
    
    func setupSlideScrollView(slides : [TutorialSlideNew]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize.height = 1.0
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func createSlides() -> [TutorialSlideNew] {
        [
            TutorialSlideNew(
                imageOne: "feed_1",
                imageTwo: "feed_map_1",
                textKey: "tutorial1"
            ),
            
            TutorialSlideNew(
                imageOne: "job_offer",
                imageTwo: "send_offer",
                textKey: "tutorial2"
            ),
            TutorialSlideNew(
                imageOne: "describe_job",
                imageTwo: "pay_swish",
                textKey: "tutorial3"
            ),
            TutorialSlideNew(
                imageOne: "job_bids",
                imageTwo: "swish_payment_app",
                textKey: "tutorial4"
            )
        ]
    }
    
    
    func pushDashboardVC(constant: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(constant)) {
            let vc =  UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        //pageControl.currentPage = Int(pageIndex)
        tutorialPage = Int(pageIndex)
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        //           let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        //
        //           if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
        //
        //               slides[0].imageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
        //               slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
        //
        //           } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
        //               slides[1].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
        //               slides[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
        //
        //           } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
        //               slides[2].imageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
        //               slides[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
        //
        //           }
    }
}

//
//  CPImageSlider.swift
//  ImageSlider
//
//  Created by Amit Singh on 28/06/17.
//  Copyright © 2017 Code Protocols. All rights reserved.
//

import UIKit
import SDWebImage

@objc protocol CPSliderDelegate: NSObjectProtocol {
	func sliderImageTapped(slider: CPImageSlider, index: Int)
    @objc optional func deleteImageBtnAction(index: Int)
}
 enum ImageSliderType {
    case stringType
    case uiImagesType
    case urlType
}


class CPImageSlider: UIView, UIScrollViewDelegate {
	
	static var leftArrowImage : UIImage?
	static var rightArrowImage : UIImage?
	
	private var view: UIView!
	
    var lastIndex : Int = 0
    var sliderType : ImageSliderType = .stringType

	@IBOutlet weak fileprivate var myScrollView: UIScrollView!
	@IBOutlet weak fileprivate var myPageControl: UIPageControl!
	
	@IBOutlet weak var pageIndicatorBottomConstraint : NSLayoutConstraint!
	
	@IBOutlet weak fileprivate var prevArrowButton : UIButton!
	@IBOutlet weak fileprivate var nextArrowButton : UIButton!
	@IBOutlet weak fileprivate var arrowButtonsView : UIView!
	
	private var currentIndex : Int = 0
	
	var allowCircular : Bool = true{
		didSet{
			addImagesOnScrollView()
		}
	}
    
    
    var addDeleteBtn : Bool = false{
        didSet{
            addImagesOnScrollView()
        }
    }
	
	var durationTime : TimeInterval = 3.0
	
	var images = [String](){
		didSet{
			myPageControl.numberOfPages = images.count
			addImagesOnScrollView()
		}
	}
    
    var uiImages = [UIImage](){
        didSet{
            myPageControl.numberOfPages = uiImages.count
            addUIImagesOnScrollView()
        }
    }
    
    var placeholderImage = UIImage()
    
    var urlArray = [String](){
        didSet{
            if urlArray != nil{
                
            }
            myPageControl.numberOfPages = urlArray.count
            addURLImagesOnScrollView()
        }
    }
	
	var enableSwipe : Bool = false{
		didSet{
			myScrollView.isUserInteractionEnabled = enableSwipe
		}
	}
	
	var enableArrowIndicator : Bool = false{
		didSet{
			arrowButtonsView.isHidden = !enableArrowIndicator
		}
	}
	
	var enablePageIndicator : Bool = false{
		didSet{
			myPageControl.isHidden = !enablePageIndicator
		}
	}
	
	private var imageViewArray : [UIImageView] = []
	
	var autoSrcollEnabled : Bool = false{
		didSet{
			checkForAutoScrolled()
		}
	}
	
	var activeTimer:Timer?
	
	@IBOutlet weak var delegate: CPSliderDelegate?
	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		xibSetup()
		resetValues()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		for index in 0..<myScrollView.subviews.count
		{
			let sub = myScrollView.subviews[index]
			sub.frame = CGRect(x: CGFloat(index)*bounds.width, y: 0, width: bounds.width, height: bounds.height)
		}
		var count = 0
        if sliderType == .stringType{
            count = images.count
        }else if sliderType == .uiImagesType{
            count = uiImages.count
        }else{
            count = urlArray.count
        }
        
		if allowCircular
		{
			count += 2
		}
		myScrollView.contentSize = CGSize(width: bounds.width*CGFloat(count), height: bounds.height)
		adjustContentOffsetFor(index: currentIndex, offsetIndex: convertIndex(), animated: false)
	}
	
	func convertIndex()->Int
	{
		if allowCircular
		{
			return currentIndex + 1
		}
		else
		{
			return currentIndex
		}
	}
	
	func resetValues()
	{
		allowCircular = true
		enableSwipe = true
		enablePageIndicator = true
		enableArrowIndicator = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		xibSetup()
		resetValues()
	}
	
	func xibSetup()
	{
		view = loadViewFromNib()
		// use bounds not frame or it'll be offset
		view.frame = bounds
		// Make the view stretch with containing view
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
		// Adding custom subview on top of our view (over any custom drawing > see note below)
		addSubview(view)
	}
	
	func loadViewFromNib() -> UIView {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: "CPImageSlider", bundle: bundle)
		// Assumes UIView is top level and only object in CPImageSlider.xib file
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		return view
	}
	
	private func adjustContentOffsetFor(index : Int, offsetIndex offset : Int, animated : Bool)
	{
		myScrollView.setContentOffset(CGPoint(x: CGFloat(offset)*bounds.width, y: 0), animated: animated)
		myPageControl.currentPage = index
		checkButtonsIfNeedsDisable()
		checkForAutoScrolled()
	}
	
    func addImagesOnScrollView()
    {
        for sub in myScrollView.subviews
        {
            sub.removeFromSuperview()
        }
        if images.count == 0
        {
            return
        }
        var count = images.count
        if allowCircular && images.count != 0
        {
            count += 2
        }
        for index in 0..<count
        {
            let imageV = getImageView(index: index)
            imageV.frame = CGRect(x: CGFloat(index)*bounds.width, y: 0, width: bounds.width, height: bounds.height)
            if allowCircular && images.count != 0
            {
                if index == 0 {
                    imageV.image = UIImage(named:images.last!)
                }
                else if index > images.count
                {
                    imageV.image = UIImage(named:images.first!)
                }
                else
                {
                    imageV.image = UIImage(named:images[index - 1])
                }
            }
            else
            {
                imageV.image = UIImage(named:images[index])
            }
            myScrollView.addSubview(imageV)
        }
        
        if count < imageViewArray.count {
            imageViewArray.removeSubrange(count..<imageViewArray.count)
        }
        myScrollView.contentSize = CGSize(width: bounds.width*CGFloat(count), height: bounds.height)
        adjustContentOffsetFor(index: currentIndex, offsetIndex: convertIndex(), animated: false)
    }
    
    func addUIImagesOnScrollView()
    {
        for sub in myScrollView.subviews
        {
            sub.removeFromSuperview()
        }
        if uiImages.count == 0
        {
            return
        }
        var count = uiImages.count
        if allowCircular && uiImages.count != 0
        {
            count += 2
        }
        for index in 0..<count
        {
            let imageV = getImageView(index: index)
            imageV.frame = CGRect(x: CGFloat(index)*bounds.width, y: 0, width: bounds.width, height: bounds.height)
            if allowCircular && uiImages.count != 0
            {
                if index == 0 {
                    imageV.image = uiImages.last
                }
                else if index > images.count
                {
                    imageV.image = uiImages.first
                }
                else
                {
                    imageV.image = uiImages[index - 1]
                }
            }
            else
            {
                imageV.image = uiImages[index]
            }
            myScrollView.addSubview(imageV)
        }
        
        if count < imageViewArray.count {
            imageViewArray.removeSubrange(count..<imageViewArray.count)
        }
        myScrollView.contentSize = CGSize(width: bounds.width*CGFloat(count), height: bounds.height)
        adjustContentOffsetFor(index: currentIndex, offsetIndex: convertIndex(), animated: false)
    }
	
    func addURLImagesOnScrollView()
    {
        for sub in myScrollView.subviews
        {
            sub.removeFromSuperview()
        }
        if urlArray.count == 0
        {
            return
        }
        var count = urlArray.count
        if allowCircular && urlArray.count != 0
        {
            count += 2
        }
        for index in 0..<count
        {
            let imageV = getImageView(index: index)
            imageV.frame = CGRect(x: CGFloat(index)*bounds.width, y: 0, width: bounds.width, height: bounds.height)
            if allowCircular && urlArray.count != 0
            {
                if index == 0 {
                    setSdImage(url: urlArray.last!, imageView: imageV)
                }
                else if index > images.count
                {
                    setSdImage(url: urlArray.first!, imageView: imageV)
                }
                else
                {
                    setSdImage(url: urlArray[index - 1], imageView: imageV)
                }
            }
            else
            {
                setSdImage(url: urlArray[index], imageView: imageV)
            }
            myScrollView.addSubview(imageV)
        }
        
        if count < imageViewArray.count {
            imageViewArray.removeSubrange(count..<imageViewArray.count)
        }
        myScrollView.contentSize = CGSize(width: bounds.width*CGFloat(count), height: bounds.height)
        adjustContentOffsetFor(index: currentIndex, offsetIndex: convertIndex(), animated: false)
    }

    func setSdImage(url: String, imageView: UIImageView){
        imageView.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage, options: .fromCacheOnly) { (image, error, cacheType, url) in
        }
    }
    
    func getImageView(index : Int)-> UIImageView
	{
		if index < imageViewArray.count
		{
			return imageViewArray[index]
		}
		
		let imageV = UIImageView()
		imageV.contentMode = .scaleAspectFill
		imageV.clipsToBounds = true
		imageV.isUserInteractionEnabled = true
        
        if(addDeleteBtn){
            let deleteBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 50, y: 10, width: 40, height: 40))
            deleteBtn.backgroundColor = UIColor.white
            deleteBtn.tintColor = UIColor.black
            deleteBtn.setHalfCornerRadius()
            deleteBtn.tag = index
            deleteBtn.addTarget(self, action: #selector(deleteBtnAction), for: .touchUpInside)
            deleteBtn.setImage(UIImage(named: "deleteIcon"), for: .normal)
            
            imageV.addSubview(deleteBtn)
        }
        
		let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(self.tapOnImage))
		imageV.addGestureRecognizer(tapOnImage)
		imageViewArray.append(imageV)
		
		return imageV
	}
	
	func createSlider(withImages images: [String], withAutoScroll isAutoScrollEnabled: Bool, in parentView: UIView)
	{
		self.frame = UIScreen.main.bounds
		self.images = images
		autoSrcollEnabled = isAutoScrollEnabled
	}
	
    @objc func tapOnImage(gesture: UITapGestureRecognizer){
		delegate?.sliderImageTapped(slider: self, index: currentIndex)
	}
	
	func getCurrentIndex()->Int
	{
		let width: CGFloat = myScrollView.frame.size.width
		return Int((myScrollView.contentOffset.x + (0.5 * width)) / width)
	}
	
	func getCurrentIndex(x : CGFloat)->Int
	{
		let width: CGFloat = myScrollView.frame.size.width
		return Int((x + (0.5 * width)) / width)
	}
	
	//#pragma mark - UIScrollView delegate
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		print(#function)
		lastIndex = getCurrentIndex()
		self.invalidateTimer()
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let index = getCurrentIndex(x: targetContentOffset.pointee.x)
		if index != lastIndex
		{
			print("\(#function)")
			currentIndex = index
			if allowCircular
			{
				currentIndex = index - 1
				if currentIndex < 0 {
					currentIndex = images.count - 1
				}else if currentIndex > images.count - 1
				{
					currentIndex = 0
				}
			}
			adjustContentOffsetFor(index: currentIndex, offsetIndex: index, animated: true)
		}
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		print(#function)
		if allowCircular && images.count != 0
		{
			if (currentIndex == 0 && myScrollView.contentOffset.x != getOffsetFor(index: 0)) || ((currentIndex == (images.count - 1)) && myScrollView.contentOffset.x != getOffsetFor(index: (images.count - 1)))
			{
				adjustContentOffsetFor(index: currentIndex, offsetIndex: convertIndex(), animated: false)
			}
		}
	}
	
	private func getOffsetFor(index : Int)->CGFloat
	{
		var tempIndex = index
		if allowCircular
		{
			tempIndex += 1
		}
		return CGFloat(tempIndex)*bounds.width
	}
	
	private func getActualOffsetFor(index : Int)->CGFloat
	{
		return CGFloat(index)*bounds.width
	}
	
	//pragma mark end
    @objc func slideImage()
	{
		let previous = currentIndex
		currentIndex = currentIndex + 1
		var convertedIndex = convertIndex()
		if currentIndex > images.count - 1 {
			if allowCircular {
				currentIndex = 0
			}
			else
			{
				currentIndex = previous
				convertedIndex = convertIndex()
			}
			
		}
		adjustContentOffsetFor(index: currentIndex, offsetIndex: convertedIndex, animated: true)
	}
	
	func checkForAutoScrolled()
	{
		if(images.count > 1 && autoSrcollEnabled){
			self .startTimerThread()
		}
		else
		{
			invalidateTimer()
		}
	}
	
	func startTimerThread()
	{
		invalidateTimer()
		activeTimer = Timer.scheduledTimer(timeInterval: durationTime, target: self, selector: #selector(self.slideImage), userInfo: nil, repeats: true)
	}
	
	func startAutoPlay() { 
		autoSrcollEnabled = true
	}
	
	func stopAutoPlay() {
		autoSrcollEnabled =  false
		invalidateTimer()
	}
	
	func invalidateTimer()
	{
		if activeTimer != nil
		{
			activeTimer!.invalidate()
			activeTimer = nil
		}
	}
	
	private func checkButtonsIfNeedsDisable()
	{
		checkIfPrevNeedsDisable()
		checkIfNextNeedsDisable()
	}
	
	private func checkIfNextNeedsDisable()
	{
		if !allowCircular && currentIndex == images.count-1  {
			nextArrowButton.isEnabled = false
		}
		else
		{
			nextArrowButton.isEnabled = true
		}
	}
	
	private func checkIfPrevNeedsDisable()
	{
		if !allowCircular && currentIndex == 0
		{
			prevArrowButton.isEnabled = false
		}
		else
		{
			prevArrowButton.isEnabled = true
		}
	}
	
	@IBAction func nextButtonPressed()
	{
		invalidateTimer()
		currentIndex = currentIndex + 1
		let convertedIndex = convertIndex()
		if currentIndex > images.count - 1 {
			currentIndex = 0
		}
		adjustContentOffsetFor(index: currentIndex, offsetIndex: convertedIndex, animated: true)
	}
	
	@IBAction func previousButtonPressed()
	{
		invalidateTimer()
		currentIndex = currentIndex - 1
		let convertedIndex = convertIndex()
		if currentIndex < 0 {
			currentIndex = images.count - 1
		}
		adjustContentOffsetFor(index: currentIndex, offsetIndex: convertedIndex, animated: true)
	}
    
    @objc func deleteBtnAction(sender: UIButton!){
        
        delegate?.deleteImageBtnAction!(index: sender.tag)
        
        if(sender.tag == uiImages.count){
            myScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
}


public struct CPButtonConfig
{
	var width : CGFloat = 30
	var height : CGFloat = 30
	var cornerRadius : CGFloat = 15
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: false)
    }
}

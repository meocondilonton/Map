

import UIKit

//MLPAutoCompleteTextField

let kHeightDropDown = CGFloat(120)
let kMarginDropDown = CGFloat(10)

let orangeColor  =   UIColor(red: 255.0/255.0, green: 90.0/255.0, blue: 24.0/255.0, alpha: 1)
let bgTextFieldGrayColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0)
let textWhiteIntroColor =  UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1)

typealias TFGraySelectItemBlock = () -> ()
typealias TFGrayIconBlock = () -> ()
typealias TFGrayDelayBlock = () -> ()
typealias TFGrayDropDownBlock = (height : CGFloat) -> ()
@IBDesignable
class TextFieldGrayCustom : UITextField,UITableViewDelegate , UITableViewDataSource {
    
    internal var selectedHandle: TFGrayIconBlock?
    internal var selectedItemHandle: TFGraySelectItemBlock?
    internal var dropDownHandle: TFGrayDropDownBlock?
    internal var delayHandle: TFGrayDelayBlock?
    
    let placeHolderColor =   UIColor(red: 212.0 / 255.0, green: 212.0 / 255.0, blue: 212.0 / 255.0, alpha: 0.6)
    let normalColor =   UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1)
    
    let highlightColor =  UIColor.whiteColor()
    let responseFailColor = orangeColor
    
    var imageView = UIImageView()
    var imageRightView = UIButton()
    var isError: Bool = false
    var isCheck: Bool = false
    var textValue:String! = ""
    
    var tableView : UITableView = UITableView()
    var vDropDownBG : UIView = UIView()
    var tableData:NSArray = [AnyObject]()
    var isFirstShowDropDown:Bool = false
    var isCurrentShowDropDown:Bool = false
    var heightViewShow:CGFloat = CGFloat(0)
    
    var currentValue:AnyObject? = nil
    var timer = NSTimer()
    var target:AnyObject?
    
    @IBInspectable var placeholderText:String = ""{
        didSet {
            //placeholder
            self.attributedPlaceholder = NSAttributedString(string: placeholderText,
                attributes:[NSForegroundColorAttributeName: textWhiteIntroColor])
        }
    }
    
    @IBInspectable var imageName: UIImage = UIImage(){
        didSet {
            //calculate the frame size
            let imageSize = 18
            let marginLeft = 19
            
            //icon
            imageView.image = imageName
            imageView.frame.origin = CGPoint(x: CGFloat(marginLeft), y: (self.frame.size.height * 0.5) - CGFloat(imageSize / 2))
            imageView.frame.size = CGSize(width: imageSize, height: imageSize)
            imageView.contentMode = UIViewContentMode.Center
            
            imageView.mas_makeConstraints { make -> Void in
                make.top.equalTo()(self.mas_top).with().offset()( (self.frame.size.height * 0.5) - CGFloat(imageSize / 2))
                make.left.equalTo()(self.mas_left).with().offset()(CGFloat(marginLeft))
                make.width.equalTo()(imageSize)
                make.height.equalTo()(imageSize)
            }
        }
    }
    
    @IBInspectable var imageNameRight: UIImage = UIImage(){
        didSet {
            //calculate the frame size
            let imageSize = 40
            let imageSizeHeight = 40
            let marginRight = 0
            
            //icon
            imageRightView.frame = CGRectMake(self.frame.size.width -  CGFloat(marginRight + imageSize), self.frame.size.height * 0.5 - CGFloat(imageSizeHeight / 2), CGFloat(imageSize), CGFloat(imageSizeHeight))
            imageRightView.setImage(imageNameRight, forState:  UIControlState.Normal)
            imageRightView.addTarget(self, action: Selector("handleTap"), forControlEvents: UIControlEvents.TouchUpInside)
            
            imageRightView.mas_makeConstraints { make -> Void in
                make.top.equalTo()(self.mas_top).with().offset()( (self.frame.size.height * 0.5) - CGFloat(imageSize / 2))
                make.right.equalTo()(self.mas_right).with().offset()(CGFloat(marginRight))
                make.width.equalTo()(imageSize)
                make.height.equalTo()(imageSize)
                
            }
            
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        backgroundColor = bgTextFieldGrayColor
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = placeHolderColor.CGColor
        font = UIFont.systemFontOfSize(12)
        textColor = normalColor
        tintColor = normalColor
        self.attributedPlaceholder = NSAttributedString(string: placeholderText,
            attributes:[NSForegroundColorAttributeName: textWhiteIntroColor])
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.frame.size.width, 0))
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.addSubview(self.imageRightView)
        self.addSubview(self.imageView)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        backgroundColor = bgTextFieldGrayColor
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.borderColor = placeHolderColor.CGColor
        font = UIFont.systemFontOfSize(12)
        textColor = normalColor
        tintColor = normalColor
        self.attributedPlaceholder = NSAttributedString(string: placeholderText,
            attributes:[NSForegroundColorAttributeName: textWhiteIntroColor])
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, self.frame.size.width, 0))
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.addSubview(self.imageRightView)
        self.addSubview(self.imageView)
    }
    
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        
        var value = super.editingRectForBounds(bounds)
        value.origin.x = imageView.frame.origin.x + imageView.frame.size.width  + 15
        value.size.width = value.size.width -  value.origin.x - 45
        
        return value
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var value = super.textRectForBounds(bounds)
        value.origin.x = imageView.frame.origin.x + imageView.frame.size.width  + 15
        value.size.width = value.size.width -  value.origin.x - 45
        
        return value
    }
    
    override func  resignFirstResponder() -> Bool {
        
        hideDropDownView()
        
        return super.resignFirstResponder()
    }
    
    //MARK: - table
    func showDropDownView (arr : NSArray) {
        let arrHeight = CGFloat(arr.count * 44 )
        let height1 = kHeightDropDown
        //        (arrHeight < kHeightDropDown) &&  (arrHeight != 0) ? arrHeight: kHeightDropDown
        if isFirstShowDropDown == false
        {
            self.vDropDownBG = UIView(frame: CGRectMake(self.superview!.frame.origin.x + self.frame.origin.x, self.frame.size.height + kMarginDropDown + self.superview!.frame.origin.y , self.frame.size.width, height1))
            self.vDropDownBG.backgroundColor = self.backgroundColor
            self.vDropDownBG.layer.cornerRadius = 20
            self.vDropDownBG.layer.masksToBounds = true
            
            self.superview?.superview?.insertSubview(self.vDropDownBG, belowSubview: self)
            //            self.superview?.superview?.addSubview(self.vDropDownBG)
            
            
            self.tableView.frame = CGRectMake(self.superview!.frame.origin.x + self.frame.origin.x,  kMarginDropDown + self.frame.size.height + self.superview!.frame.origin.y , self.frame.size.width - 20 , height1)
            self.tableView.backgroundColor = UIColor.clearColor()
            self.tableView.tableFooterView = UIView()
            self.tableView.allowsSelection = true
            self.superview?.superview?.insertSubview(self.tableView, belowSubview: self)
            //            self.superview?.superview?.addSubview(self.tableView)
            
            
            isFirstShowDropDown = true
        }else{
            
            self.vDropDownBG.frame =  CGRectMake(self.superview!.frame.origin.x + self.frame.origin.x, self.frame.size.height + kMarginDropDown + self.superview!.frame.origin.y , self.frame.size.width, height1)
            self.tableView.frame = CGRectMake(self.superview!.frame.origin.x + self.frame.origin.x ,  kMarginDropDown + self.frame.size.height + self.superview!.frame.origin.y , self.frame.size.width - 20, height1)
            
        }
        heightViewShow =  kMarginDropDown + height1 + self.frame.size.height
        if arr.count <= 0 {
            hideDropDownView ()
            return
        }
        
        self.handleDropDown(heightViewShow)
        self.tableView.hidden = false
        self.vDropDownBG.hidden = false
        updateDataSource (arr)
        isCurrentShowDropDown = true
    }
    
    func hideDropDownView () {
        self.handleDropDown(self.frame.size.height)
        self.tableView.hidden = true
        self.vDropDownBG.hidden = true
        isCurrentShowDropDown = false
    }
    
    //MARK: Table delegate
    func updateDataSource (arr : NSArray) {
        tableData = arr
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        
        cell.backgroundColor = UIColor.clearColor()
        let item: AnyObject = tableData[indexPath.row]
        cell.textLabel?.text = item.autocompleteString()
        cell.textLabel?.font = self.font
        cell.textLabel?.textColor = self.textColor
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        hideDropDownView()
        let item: AnyObject = tableData[indexPath.row]
        self.text  = item.autocompleteString()
        if item is Place {
            getDetails((item as! Place)) { (result:PlaceDetails) -> () in
                self.currentValue = result
                if self.selectedItemHandle != nil {
                    self.selectedItemHandle!()
                }
            }
        }else{
            self.currentValue = item
        }
        
        
        self.resignFirstResponder()
        
    }
    //MARK: - request place
    func getDetails(place:Place ,result: PlaceDetails -> ()) {
        GooglePlaceDetailsRequest(place: place).request(result)
    }
    
    
    //MARK: - delegate
    func handleDropDown(height : CGFloat) {
        if self.dropDownHandle != nil {
            self.dropDownHandle!(height: height)
        }
    }
    
    func handleTap() {
        if self.selectedHandle != nil {
            self.selectedHandle!()
        }
        
    }
    
    func runActionAfterDelay(block:TFGrayDelayBlock) {
        let param =  NSMutableDictionary()
        
        self.delayHandle = block
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateAction", userInfo: param, repeats: false)
        
        
    }
    
    func updateAction() {
        if self.delayHandle != nil {
            self.delayHandle!()
        }
    }
    
    func beginType() {
        self.attributedPlaceholder = NSAttributedString(string: placeholderText,
            attributes:[NSForegroundColorAttributeName: textWhiteIntroColor ])
        layer.borderColor = placeHolderColor.CGColor
    }
    
    func responseFail(strErr : String){
        
        textValue = text
        text = ""
        self.attributedPlaceholder = NSAttributedString(string: strErr,
            attributes:[NSForegroundColorAttributeName: responseFailColor])
        layer.borderColor = responseFailColor.CGColor
        
    }
    
}
//
//  DrawViewController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/16.
//
import UIKit
import PencilKit
import PhotosUI
import SnapKit
import Photos
import Instructions

protocol DrawViewControllerDelegate : AnyObject {
    func vcDidFinish(_ vc : DrawViewController)
}

class DrawViewController: UIViewController , PKCanvasViewDelegate {
//MARK: - Properties
    var section : Int
    
    private var user : User
    
    weak var delegate : DrawViewControllerDelegate?
    
    init(user : User, section : Int) {
        self.user = user
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let canvasView = PKCanvasView()
    
    private var canvasImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private let drawing = PKDrawing()
    
    private var toolPicker : PKToolPicker = {
       let tool = PKToolPicker()
       return tool
   }()
    private let toggleButton : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "pencil.tip.crop.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapToggle), for: .touchUpInside)
        return button
    }()
    private let clearButton : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "clear")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        return button
    }()
    private let saveButton : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.down")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()
    private let photoButton : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "photo")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didTapPhoto), for: .touchUpInside)
        return button
    }()
    private let imageResetButton : UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "trash.circle")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(didReset), for: .touchUpInside)
        return button
    }()
    // ??????????????? ??????????????? ????????????
    let coachController = CoachMarksController()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        coachControllSetup()
        configureUI()
        setupNavigation()
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.coachController.start(in: .window(over: self))
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.coachController.stop(immediately: true)
    }
    //MARK: -Configure
    func configureUI(){
        view.addSubview(canvasImageView)
        canvasImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        view.addSubview(canvasView)
        canvasView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        canvasView.insertSubview(canvasImageView, at: 0)
        let stackView = UIStackView(arrangedSubviews: [toggleButton,clearButton,saveButton,photoButton,imageResetButton])
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(5)
            make.leading.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
    }
    func configure() {
        view.backgroundColor = .white
        switch section {
        case 0 :
            title = "ThumbNail"
        case 1 :
            title = "PAGE-1"
        case 2 :
            title = "PAGE-2"
        case 3 :
            title = "PAGE-3"
        default :
            title = "PAGE-4"
        }
    }
    func setupNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "??????", style: .plain, target: self,action: #selector(successHandle))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "??????", style: .done, target: self, action: #selector(cancelHandel))
    }
    //MARK: - CoachControllerSetUp
    func coachControllSetup(){
        self.coachController.dataSource = self
        self.coachController.delegate = self
        self.coachController.overlay.isUserInteractionEnabled = true
        // ????????? ?????????
        let skip = CoachMarkSkipDefaultView()
        skip.setTitle("Skip", for: .normal)
        self.coachController.skipView = skip
        self.coachController.statusBarVisibility = .hidden
        // ???????????????
        self.coachController.animationDelegate = self
    }
    //MARK: - @objc Method
    @objc func successHandle(){
        let alert = UIAlertController(title: "?????????", message: "????????????????????????????", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            self.cartoonLoad()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func cancelHandel(){
        let alert = UIAlertController(title: "????????????", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            self.delegate?.vcDidFinish(self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func didTapToggle(){
        if canvasView.isFirstResponder{
            canvasView.resignFirstResponder()
        }else{
            canvasView.becomeFirstResponder()
        }
    }
    @objc func didTapClear(){
        let alert = UIAlertController(title: "????????????", message: "????????? ?????? ???????????????.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            self.canvasView.drawing = PKDrawing()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func didTapSave(){
        let alert = UIAlertController(title: "????????? ??????", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, true, UIScreen.main.scale)
            self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if image != nil {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image!)
                }, completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func didTapPhoto(){
        let alert = UIAlertController(title: "????????? ????????????", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { act in
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 1 // ??????????????? 1?????? ??????.. ????????? ????????? 4????????? ?????? ????????? ?????? ????????????
            config.filter = .images // ???????????? ??????????????????
            let pickerVC = PHPickerViewController(configuration: config) //PickerViewController
            pickerVC.delegate = self
            self.present(pickerVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @objc func didReset(){
        canvasImageView.image = nil
        canvasView.isHidden = false
    }
    //MARK: - Cartoon Method
    func cartoonLoad(){
        createImage { image in
            let jpgImage = image.jpegData(compressionQuality: 0.8)
            switch self.section {
            case 0 :
                UserDefaults.standard.set(jpgImage, forKey: "thumbnail")
                UserDefaults.standard.synchronize()
            case 1 :
                UserDefaults.standard.set(jpgImage, forKey: "page1")
                UserDefaults.standard.synchronize()
            case 2 :
                UserDefaults.standard.set(jpgImage, forKey: "page2")
                UserDefaults.standard.synchronize()
            case 3 :
                UserDefaults.standard.set(jpgImage, forKey: "page3")
                UserDefaults.standard.synchronize()
            default :
                UserDefaults.standard.set(jpgImage, forKey: "page4")
                UserDefaults.standard.synchronize()
            }
        }
        canvasView.drawing = PKDrawing()
        canvasImageView.image = nil
        canvasImageView.isHidden = true
        self.delegate?.vcDidFinish(self)
    }
    //MARK: - CreateImage Method
    func createImage(completion:@escaping (UIImage) -> Void){
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, true, UIScreen.main.scale)
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // ???????????? ???????????? ????????? ?????? ???????????? ???????????????
        guard let image = image else { return }
        completion(image)
    }
}
//MARK: - PHPickerViewControllerDelegate
extension DrawViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { bridge, error in
                guard let image = bridge as? UIImage,error == nil else { return }
                DispatchQueue.main.async {
                    self.canvasView.backgroundColor = .clear
                    self.canvasView.isOpaque = false
                    self.canvasImageView.image = image
                    self.canvasImageView.isHidden = false
                }
            }
        }
    }
}
//MARK: - CoachMarksControllerDataSource
extension DrawViewController : CoachMarksControllerDataSource {
    
    // ???????????? ??????????????? Method
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coach = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        switch index {
        case 0:
            coach.bodyView.hintLabel.text = "??????????????? ????????? ????????? ?????????!"
            coach.bodyView.nextLabel.text = "????????????"
            coach.bodyView.nextLabel.textColor = .lightGray
            coach.bodyView.hintLabel.textColor = .black
            coach.bodyView.background.borderColor = UIColor.yellow
            coach.arrowView?.background.innerColor = .yellow
        case 1:
            coach.bodyView.hintLabel.text = "?????? ????????? ????????? ?????????!"
            coach.bodyView.nextLabel.text = "????????????"
            coach.bodyView.nextLabel.textColor = .lightGray
            coach.bodyView.hintLabel.textColor = .black
            coach.bodyView.background.borderColor = UIColor.yellow
        case 2:
            coach.bodyView.hintLabel.text = "????????? ???????????? ???????????? ?????????!"
            coach.bodyView.nextLabel.text = "????????????"
            coach.bodyView.nextLabel.textColor = .lightGray
            coach.bodyView.hintLabel.textColor = .black
            coach.bodyView.background.borderColor = UIColor.yellow
        case 3:
            coach.bodyView.hintLabel.text = "????????? ????????? ??????????????? ?????????!"
            coach.bodyView.nextLabel.text = "????????????"
            coach.bodyView.nextLabel.textColor = .lightGray
            coach.bodyView.hintLabel.textColor = .black
            coach.bodyView.background.borderColor = UIColor.yellow
        case 4:
            coach.bodyView.hintLabel.text = "????????? ????????? ????????? ?????????!"
            coach.bodyView.nextLabel.text = "????????????"
            coach.bodyView.nextLabel.textColor = .lightGray
            coach.bodyView.hintLabel.textColor = .black
            coach.bodyView.background.borderColor = UIColor.yellow
        default:
            fatalError()
        }
        return (bodyView:coach.bodyView,arrowView: coach.arrowView)
    }
    // ??? ??????????????? Method . ????????? ??????????????? ???
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: toggleButton )
        case 1:
            return coachMarksController.helper.makeCoachMark(for: clearButton )
        case 2:
            return coachMarksController.helper.makeCoachMark(for: saveButton )
        case 3:
            return coachMarksController.helper.makeCoachMark(for: photoButton )
        case 4:
            return coachMarksController.helper.makeCoachMark(for: imageResetButton )
        default:
            fatalError()
        }
    }
    // ???????????? ????????? ?????? ????????? ????????? Method
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 5
    }
}
//MARK: - CoachMarksControllerDelegate
extension DrawViewController : CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController, configureOrnamentsOfOverlay overlay: UIView) {
        let label = UILabel()
        overlay.addSubview(label)
        label.text = "????????? ????????? ??????"
        label.alpha = 0.5
        label.font = label.font.withSize(20.0)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
extension DrawViewController : CoachMarksControllerAnimationDelegate {
    // Marker ??????
    func coachMarksController(_ coachMarksController: CoachMarksController, fetchAppearanceTransitionOfCoachMark coachMarkView: UIView, at index: Int, using manager: CoachMarkTransitionManager) {
        manager.parameters.options = [.beginFromCurrentState]
        manager.animate(.regular) { (CoachMarkAnimationManagementContext) in
            coachMarkView.transform = .identity
            coachMarkView.alpha = 1
        } fromInitialState: {
            // ????????? ??????,?????? ?????? ??? ??????
            coachMarkView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            coachMarkView.alpha = 0
        } completion: { (Bool) in
        }
    }
    // Marker ??????
    func coachMarksController(_ coachMarksController: CoachMarksController, fetchDisappearanceTransitionOfCoachMark coachMarkView: UIView, at index: Int, using manager: CoachMarkTransitionManager) {
        manager.animate(.keyframe) { (CoachMarkAnimationManagementContext) in
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.8) {
                // ????????????
                coachMarkView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }
        UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.4) {
            coachMarkView.alpha = 0
        }
    }
    // Marker ??????
    func coachMarksController(_ coachMarksController: CoachMarksController, fetchIdleAnimationOfCoachMark coachMarkView: UIView, at index: Int, using manager: CoachMarkAnimationManager) {
        manager.parameters.options = [.repeat,.autoreverse,.allowUserInteraction]
        manager.parameters.duration = 0.5
        manager.animate(.regular) { (context : CoachMarkAnimationManagementContext) in
            let offset : CGFloat = context.coachMark.arrowOrientation == .top ? 10 : -10
            coachMarkView.transform = CGAffineTransform(translationX: 0, y: offset)
        }

    }
}

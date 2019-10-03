#import "DSInspectionStickerViewModel.h"
#import "DriverInspectionStickerViewController.h"
#import "NSString+Utils.h"
#import "Ride-Swift.h"
#import "UICustomDatePicker.h"
#import "UIImage+Ride.h"
#define kInspectionStickerExpiryDate @"kInspectionStickerExpiryDate"

@interface DriverInspectionStickerViewController ()

@property (nonatomic) KLCPopup *datePopup;
@property (nonatomic) DSInspectionStickerViewModel *viewModel;
@property (strong, nonatomic) RAPhotoPickerControllerManager *pickerManager;
@property (strong, nonatomic) IBOutlet UICustomDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *lblContent;
@property (weak, nonatomic) IBOutlet UITextField *txtExpirationDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgInspectionSticker;

@end

@implementation DriverInspectionStickerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
    [self configureNavigationBar];
    [self configureDatePicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
}

- (void)configureNavigationBar {
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.inspectionStickerViewModel;
    
    self.title = self.viewModel.headerText;
    self.lblTitle.text = self.viewModel.title;
    self.lblContent.text = self.viewModel.subTitle;

    if (self.viewModel.cachedImage) {
        [self setImageSelected:self.viewModel.cachedImage];
    }
    
    //Setup Textfield Expiration Date
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.txtExpirationDate.bounds.size.height)];
    self.txtExpirationDate.leftView = leftView;
    self.txtExpirationDate.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.txtExpirationDate.bounds.size.height)];
    UIImageView *iconCalendar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-calendar"]];
    [iconCalendar setBounds:CGRectMake(0, 0, 18, 20)];
    [rightView addSubview:iconCalendar];
    iconCalendar.center = rightView.center;
    self.txtExpirationDate.rightView = rightView;
    self.txtExpirationDate.rightViewMode = UITextFieldViewModeAlways;
    
    self.txtExpirationDate.layer.borderWidth = 1;
    self.txtExpirationDate.layer.borderColor = [UIColor grayColor].CGColor;
    self.txtExpirationDate.layer.cornerRadius = 3.0;
    self.txtExpirationDate.layer.masksToBounds = YES;
}

- (void)configureDatePicker {
    //Setup Date Picker
    self.datePicker.minDate = [NSDate date];
    self.datePicker.maxDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*365*20];
    self.datePicker.currentDate = [NSDate date];
    self.datePicker.order = NSCustomDatePickerOrderMonthDayAndYear;
    self.datePicker.option = NSCustomDatePickerOptionLongMonth | NSCustomDatePickerOptionYear;
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setBackgroundColor:[UIColor whiteColor]];
    
    if ([self.viewModel.expirationDate isKindOfClass:NSDate.class]) {
        [self setDateSelected:self.viewModel.expirationDate];
        self.datePicker.currentDate = self.viewModel.expirationDate;
    }
}

- (void)dateChanged:(UICustomDatePicker *)sender{
    self.viewModel.expirationDate = sender.currentDate;
    [self setDateSelected:self.viewModel.expirationDate];
}

- (void)setImageSelected:(UIImage *)image {
    self.imgInspectionSticker.image = image;
}
- (void)setDateSelected:(NSDate *)dateSelected {
    self.txtExpirationDate.text = [self.formatter stringFromDate:dateSelected];
}

- (NSDateFormatter*)formatter{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/yyyy"];
    }
    return formatter;
}

#pragma mark - IBActions

- (IBAction)takePhotoPressed:(id)sender {
    [self.view endEditing:YES];
    
    __weak DriverInspectionStickerViewController *weakSelf = self;
    self.pickerManager = [RAPhotoPickerControllerManager pickerManager];
    [self.pickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            BOOL valid = [weakSelf isImageValid:image];
            if (valid) {
                CGFloat maxArea = 480000;
                image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
            }
            UIImage *validImage = valid ? image : nil;
            [weakSelf.viewModel saveImage:validImage];
            [weakSelf setImageSelected:validImage];
        }
    } cancelledBlock:nil];
}

- (void)didTapNext {

    if (!self.viewModel.cachedImage) {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessage
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    if (!self.viewModel.expirationDate) {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationDateMessage
                                    andOptions:[RAAlertOption optionWithState:StateActive]];
        return;
    }
    
    [self.coordinator showNextScreenFromScreen:DSScreenCarSticker];
}

#pragma mark - UITextfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.txtExpirationDate) {
        [self.view endEditing:YES];
        self.datePopup = [KLCPopup popupWithContentView:self.datePicker showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
        [self.datePopup show];
    }
}

@end

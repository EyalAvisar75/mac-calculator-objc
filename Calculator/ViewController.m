//
//  ViewController.m
//  Calculator
//
//  Created by eyal avisar on 07/04/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//
//start with an operation deal with = %
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UIButton *ACButton;
@property (nonatomic, strong) NSMutableString *number1;
@property (nonatomic, strong) NSMutableString *number2;
@property (nonatomic, strong) NSMutableString *operation1;
@property (nonatomic, strong) NSMutableString *operation2;
@property (nonatomic, strong) NSMutableString *number3;
@property BOOL isLastDigit;
@property BOOL isPlusMinus;
@property BOOL isThirdNumber;
@end

@implementation ViewController

- (void)showValue {
    if (![self.screenLabel.text isEqualToString:@"Not a number"]) {
        double value = [self.screenLabel.text doubleValue];
        self.screenLabel.text = [NSString stringWithFormat:@"%40.20g",value];
        
    }
}

- (IBAction)handleDigit:(id)sender {
    self.isThirdNumber = ([self.number2 isEqualToString:@""])?NO:YES;
    if (!self.isLastDigit || self.isPlusMinus) {
        self.screenLabel.text = @"0";
        [self showValue];
    }
    self.isPlusMinus = NO;
    self.isLastDigit = YES;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
    if ([self.screenLabel.text isEqualToString:@"0"]){
        self.screenLabel.text = pressedText;
        [self showValue];
    }
    else {
        self.screenLabel.text = [self.screenLabel.text stringByAppendingString:pressedText];
        [self showValue];
    }
    [self.ACButton setTitle:@"C" forState:UIControlStateNormal];
}
- (IBAction)handleDot:(id)sender {
    UIButton *pressed = (UIButton *) sender;
    if ([self.screenLabel.text containsString:@"."]) {
        return;
    }
    self.screenLabel.text = [self.screenLabel.text stringByAppendingString:pressed.titleLabel.text];
    [self showValue];
}
- (IBAction)handlePlusMinus:(id)sender {
    self.isPlusMinus = YES;
    NSString *number = [[NSString alloc] initWithString: self.screenLabel.text];
    double value = [number doubleValue];
    if(value != 0)
        value = value * -1;
    self.screenLabel.text = [NSString stringWithFormat:@"%40.20g",value];
}
- (void)cancelProgression:(NSString *)forOperation readyForProgression:(BOOL *)readyForProgression isEqual:(BOOL *)isEqual operation:(NSString *)tempOperation {
    if(*readyForProgression &&
       !([forOperation isEqualToString:@"="] ||
         [forOperation isEqual:@"%"])){
        if (tempOperation) {
            NSString *number = [NSString new];
            if(self.isThirdNumber)
                number = [NSString stringWithString:self.number2];
            else
                number = [NSString stringWithString:self.number1];

            if ([tempOperation isEqualToString:@"X"]) {
                self.screenLabel.text = [self multiply:@[number, self.screenLabel.text]];
            }
            else if ([tempOperation isEqualToString:@"/"]) {
                self.screenLabel.text = [self divide:@[number, self.screenLabel.text]];
            }
            else if ([tempOperation isEqualToString:@"+"]) {
                self.screenLabel.text = [self add:@[number, self.screenLabel.text]];
            }
            else {
                self.screenLabel.text = [self subtract:@[number, self.screenLabel.text]];
            }
        }
        if(self.isThirdNumber && ![forOperation isEqualToString:@"cancel"]) {
            if ([self.operation1 isEqualToString:@"+"]) {
                self.screenLabel.text = [self add:@[self.number1, self.screenLabel.text]];
                }
            else {
                self.screenLabel.text = [self subtract:@[self.number1, self.screenLabel.text]];
            }
            
        }

        *readyForProgression = NO;
        *isEqual = NO;
        [self editData];
        [self.number1 setString:@""];
    }
}

- (BOOL)editOperation1:(NSString *)operationCandidate readyForProgression:(BOOL)readyForProgression {
    if (!readyForProgression && [self.operation1 isEqualToString:@""]) {
        if ([operationCandidate isEqualToString:@"="]) {
            return NO;
        }
        if ([operationCandidate isEqualToString:@"%"]) {
            double value = [self.screenLabel.text doubleValue] / 100.0;
            self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
            return NO;
        }
        [self.operation1 setString:operationCandidate];
    }
     return YES;
}

- (void)editOperation2:(NSString *)operationCandidate {
    if(![self.number2 isEqualToString:@""] &&
       ([operationCandidate isEqualToString:@"X"] ||
        [operationCandidate isEqualToString:@"/"])){
        [self.operation2 setString:operationCandidate];
        self.isLastDigit = NO;
        return;
    }
}

- (BOOL)editNumber:(BOOL)readyForProgression {
    if (!readyForProgression && [self.number1 isEqualToString:@""]) {
        [self.number1 setString:self.screenLabel.text];
        return YES;
    }
    else if(!readyForProgression && [self.number2 isEqualToString:@""]){
        [self.number2 setString:self.screenLabel.text];
        return YES;
    }
    else if(!readyForProgression && [self.number3 isEqualToString:@""]){
        [self.number3 setString:self.screenLabel.text];
        return YES;
    }
    return NO;
}

- (void)multiplyBinary:(NSString *)operationToSet {
    self.screenLabel.text = [self multiply:@[self.number1, self.number2]];
    double value = [self.screenLabel.text doubleValue];
    self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
    [self editData];
    [self.operation1 setString:operationToSet];
}

- (void)divideBinary:(NSString *)operationToSet {
    self.screenLabel.text = [self divide:@[self.number1, self.number2]];
    double value = [self.screenLabel.text doubleValue];
    self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
    [self editData];
    [self.operation1 setString:operationToSet];
}

- (void)multiplyTernaryExpression:(NSString *)operationToSet {
    NSString * result = [self multiply:@[self.number2, self.screenLabel.text]];
    if([self.operation1 isEqualToString:@"+"])
        self.screenLabel.text = [self add:@[self.number1, result]];
    else
        self.screenLabel.text = [self subtract:@[self.number1, result]];
    [self editData];
    [self.operation1 setString:operationToSet];
}

- (void)divideTernaryExpression:(NSString *)operationToSet {
    if([self.screenLabel.text isEqualToString:@"0"]){
        self.screenLabel.text = @"Not a number";
        return;
    }
    NSString * result = [self divide:@[self.number2, self.screenLabel.text]];
    if([self.operation1 isEqualToString:@"+"])
        self.screenLabel.text = [self add:@[self.number1, result]];
    else
        self.screenLabel.text = [self subtract:@[self.number1, result]];
    [self editData];
    [self.operation1 setString:operationToSet];
}

- (void)resetOperation2:(NSString *)operationCandidate {
    if (![self.operation2 isEqualToString:@""] &&
        ![self.number3 isEqualToString:@""]){
        [self.operation2 setString:operationCandidate];
    }
}

static void doChainAddition(ViewController *object, NSString *pressedText) {
    if([object.operation1 isEqualToString:@"+"]){
        object.screenLabel.text = [object add:@[object.number1, object.number2]];
        [object.operation2 setString:pressedText];
        [object editData];
    }
    else if(![object.number2 isEqualToString:@""]){
        object.screenLabel.text = [object subtract:@[object.number1, object.number2]];
        [object.operation2 setString:pressedText];
        [object editData];
    }
}

- (IBAction)handleOperations:(id)sender {
    static BOOL readyForProgression = NO;
    static BOOL isEqualProgression = NO;
    static NSString *tempOperation;
    NSMutableString *pressedText = [[NSMutableString alloc] initWithString:((UIButton *)sender).titleLabel.text];
    if(readyForProgression &&
    !([pressedText isEqualToString:@"="] ||[pressedText isEqual:@"%"]))
        [self cancelProgression:@"cancel" readyForProgression:&readyForProgression isEqual:&isEqualProgression operation:tempOperation];
    if(![self editOperation1:pressedText readyForProgression:readyForProgression])
        return;
    [self editNumber:readyForProgression];
    [self editOperation2:pressedText];
    
    self.isLastDigit = NO;
    self.isPlusMinus = NO;
    //start solving exercises
    if ([pressedText isEqualToString:@"="]) {//||readyForProgression
        if (readyForProgression && !isEqualProgression) {
            [pressedText setString:@""];
            NSString *number1 = [[NSString alloc] initWithString:self.screenLabel.text];
            [self cancelProgression:pressedText readyForProgression:&readyForProgression isEqual:&isEqualProgression operation:tempOperation];
            [self.operation1 setString:tempOperation];
            [self.number1 setString:number1];
            return;
        }
        isEqualProgression = YES;
        if ([pressedText isEqualToString:@"%"]) {
            double value = [self.screenLabel.text doubleValue] / 100.0;
            self.screenLabel.text = [NSString stringWithFormat:@"%40.20g",value];
            return;
        }
        NSMutableString *number1 = [NSMutableString stringWithString: self.screenLabel.text];
        NSMutableString *number2 = [NSMutableString stringWithString: self.number1];
        [self calculateProgressionTerm:@[number1, number2]];
        self.isLastDigit = YES;
        readyForProgression = YES;
        return;
    }
    if([pressedText isEqualToString:@"%"]) {
        NSMutableString *number1 = [NSMutableString stringWithString: self.screenLabel.text];
        NSMutableString *number2 = [NSMutableString stringWithString: self.number1];
        [self percentProgression:@[number2, number1, @"%"]];
        if(!self.isThirdNumber)
            tempOperation = [[NSString alloc] initWithString:self.operation1];
        else
            tempOperation = [[NSString alloc] initWithString:self.operation2];
        readyForProgression = true;
        self.isLastDigit = YES;
        return;
    }
    
    readyForProgression = NO;
    //deal with the result on the screen
    if ([self.operation1 isEqualToString:@"X"] &&
        ![self.number2 isEqualToString:@""]) {
        [self multiplyBinary:pressedText];
        return;
    }
    if ([self.operation1 isEqualToString:@"/"] &&
        ![self.number2 isEqualToString:@""]) {
        [self divideBinary:pressedText];
        return;
    }
    if(!self.isThirdNumber)
        [self resetOperation2:pressedText];
    if ([self.operation2 isEqualToString:@"X"] &&
        ![self.number3 isEqualToString:@""]) {
        [self multiplyTernaryExpression:pressedText];
        return;
    }
    if ([self.operation2 isEqualToString:@"/"] &&
        ![self.number3 isEqualToString:@""]) {
        [self divideTernaryExpression:pressedText];
        return;
    }
    if (![self.number2 isEqualToString:@""] &&
        ([pressedText isEqualToString:@"+"] ||
        [pressedText isEqualToString:@"-"])) {
        doChainAddition(self, pressedText);
    }
    
}

- (IBAction)handleAC:(id)sender {
    UIButton *pressed = (UIButton *) sender;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
    if([pressedText isEqualToString:@"AC"]){
        self.number1 = [NSMutableString new];
        self.number2 = [NSMutableString new];
        self.operation1 = [NSMutableString new];
        self.operation2 = [NSMutableString new];
        self.number3 = [NSMutableString new];
        self.isLastDigit = NO;
        self.screenLabel.text = @"0";
        [self showValue];
    }
    else {
        [pressed setTitle:@"AC" forState:UIControlStateNormal];
        if(self.isLastDigit){
            self.screenLabel.text = @"0";
            if (![self.number2 isEqualToString:@""]) {
                [self.number2 setString:@""];
            }
            else {
                [self.number1 setString:@""];
            }
        }
        else {
            if (![self.operation2 isEqualToString:@""]) {
                [self.number2 setString:@""];
            }
            else {
                [self.operation1 setString:@""];
            }
        }
    }
}

- (void)viewDidLoad {
    self.number1 = [NSMutableString new];
    self.number2 = [NSMutableString new];
    self.operation1 = [NSMutableString new];
    self.operation2 = [NSMutableString new];
    self.number3 = [NSMutableString new];
    [self showValue];
}

-(NSString *)add:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] + [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)subtract:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] - [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)multiply:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] * [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)divide:(NSArray *)numbers {
    if ([numbers[1] doubleValue] == 0) {
        return @"Not a number";
    }
    double result = [numbers[0] doubleValue] / [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(void) editData {
    [self.number1 setString:self.screenLabel.text];
    [self.number2 setString:@""];
    [self.number3 setString:@""];
    if (![self.operation2 isEqualToString:@""]) {
        [self.operation1 setString:self.operation2];
        [self.operation2 setString:@""];
    }
    else
        [self.operation1 setString:@""];
}
- (void)percentProgression:(NSArray *)numbers {
    if (numbers.count == 3) {
        double value = [numbers[1] doubleValue] * [numbers[0] doubleValue] /100.0;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
        return;
    }
}

-(void)calculateProgressionTerm:(NSArray *)numbers {
    if (![self.operation2 isEqualToString:@""]) {
        double value = 0;
        if ([self.operation2 isEqualToString:@"X"]) {
            if([self.operation1 isEqualToString:@"+"]){
                value = ([numbers[1] doubleValue] + 1) * [numbers[0] doubleValue];
            }
            else {
                value = ([numbers[1] doubleValue] - 1) * [numbers[0] doubleValue];
            }
        }
        else if ([self.operation2 isEqualToString:@"/"]) {
            if([numbers[1] doubleValue] == 0){
                self.screenLabel.text = @"Not a number";
                return;
            }
            if([self.operation1 isEqualToString:@"+"]){
                value = [numbers[1] doubleValue] / [numbers[0] doubleValue] + [numbers[0] doubleValue];
            }
            else {
                value = [numbers[1] doubleValue] / [numbers[0] doubleValue] - [numbers[0] doubleValue];
            }
        }
        //[self.number1 setString:[NSString stringWithFormat:@"%40.15g",value]];
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
        [self.operation1 setString:self.operation2];
        [self.operation2 setString:@""];
        return;
    }
    NSMutableArray *reverseNums = [NSMutableArray new];
    reverseNums[0] = numbers[1];
    reverseNums[1] = numbers[0];
    if (![numbers[0] isEqualToString:numbers[1]] &&
        ![numbers[0] isEqualToString:self.number2]) {
        [numbers[0] setString:self.screenLabel.text];
        [numbers[1] setString:self.number2];
        reverseNums[0] = numbers[0];
        reverseNums[1] = numbers[1];
    }
    if ([self.operation1 isEqualToString:@"+"]) {
        self.screenLabel.text = [self add:numbers];
    }
    else if([self.operation1 isEqualToString:@"-"]) {
        self.screenLabel.text = [self subtract:reverseNums];
    }
    else if([self.operation1 isEqualToString:@"X"]) {
        self.screenLabel.text = [self multiply:numbers];
    }
    else if([self.operation1 isEqualToString:@"/"]) {
        if([reverseNums[0] doubleValue] == 0){
            self.screenLabel.text = @"Not a number";
            return;
        }
        self.screenLabel.text = [self divide:reverseNums];
    }
    
    
}
@end

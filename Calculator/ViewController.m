//
//  ViewController.m
//  Calculator
//
//  Created by eyal avisar on 07/04/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UIButton *ACButton;
@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) NSMutableArray *operations;
@property BOOL isLastDigit;
@property BOOL isPlusMinus;
@property BOOL isProgression;
@property BOOL isPercentageProgression;
@property NSMutableArray *progressionNumbersArray;
@property NSMutableArray *progressionOperationsArray;
@end
//deal with 7+4X%= -> 7 + 0.16 * 4^1 %% 7+0.000256 * 4^2

@implementation ViewController

- (IBAction)handleDigit:(id)sender {
    if (!self.isLastDigit) {
        self.screenLabel.text = @"0";
    }
    self.isLastDigit = YES;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
    NSString *number = self.screenLabel.text;
    if([pressedText isEqual:@"+/-"]){
        self.isLastDigit = NO;
        double value = [number doubleValue];
        if(value != 0)
            value = value * -1;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
        self.isPlusMinus = YES;
        return;
    }
    BOOL isDecimal = [number containsString:@"."];

    if(isDecimal && [pressedText isEqual:@"."])
        return;
    if([pressedText isEqual:@"."])
        number = [number stringByAppendingString:pressedText];
    else {
        if(!isDecimal){
            double value = [number doubleValue] * 10 + [pressedText doubleValue];
            number = [NSString stringWithFormat:@"%40.15g", value];
        }
        else
            number = [number stringByAppendingString:pressedText];
    }
    self.screenLabel.text = number;
    [self.ACButton setTitle:@"C" forState:UIControlStateNormal];
}


-(void)cancelProgression:(NSMutableString *)pressedText {


    
}

- (void)prepareForProgression:(NSMutableString *)pressedText {
    
}



- (BOOL)calculateMultiplication:(NSArray *)numbers operation:(NSString *)operation {
    if([operation isEqual:@"X"]){
        self.screenLabel.text = [self multiply:numbers];
        return YES;
    }
    else if([operation isEqual:@"/"]){
        self.screenLabel.text = [self divide:numbers];
        return YES;
    }
    return NO;
}

- (BOOL)calculateAddition:(NSArray *)numbers operation:(NSString *)operation{
    if([operation isEqual:@"+"]){
        self.screenLabel.text = [self add:numbers];
        return YES;
    }
    else if([operation isEqual:@"-"]){
        self.screenLabel.text = [self subtract:numbers];
        return YES;
    }
    return NO;
}

- (IBAction)handleOperations:(id)sender {
    UIButton *pressed = (UIButton *)sender;
    if(self.isLastDigit || self.isPlusMinus){
        [self.numbers addObject:self.screenLabel.text];
        [self.operations addObject:[pressed currentTitle]];
        [self calculate];
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        self.isLastDigit = NO;
        self.isPlusMinus = NO;
        if(!([[pressed currentTitle] isEqual:@"="] ||
             [[pressed currentTitle] isEqual:@"%"]))
            return;
    }
    else if(self.numbers.count == 0){
        self.numbers[0] = @"0";
    }
    
    if([[pressed currentTitle] isEqual:@"="] ||
            [[pressed currentTitle] isEqual:@"%"]){
        //[self.numbers addObject:self.screenLabel.text];
        //[self.operations addObject:[pressed currentTitle]];
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        [self calculateProgression];
        self.isLastDigit = NO;
    }
    else {
        [self.operations removeLastObject];
        [self.operations addObject:[pressed currentTitle]];
        NSLog(@"ops %@",self.operations);
        NSLog(@"nums %@",self.numbers);
    }
}

- (void)calculated1Numbers {
    NSLog(@"calculated1Numbers");
    [self.numbers removeAllObjects];
    [self.operations removeObjectAtIndex:0];
    [self.numbers addObject:self.screenLabel.text];
}

-(void)calculateProgression{
//    static NSString *operation = nil;
//    if(!operation){
//        operation = [self.operations lastObject];
//
//    }
    [self.progressionOperationsArray addObject:[self.operations lastObject]];
    [self.operations removeLastObject];
    NSLog(@"ops %@ pops %@", self.operations, self.progressionOperationsArray);
    if(self.numbers.count - self.operations.count == 0){
        
    }
    if(self.progressionNumbersArray.count == 0){
        [self.progressionOperationsArray addObject:[self.operations lastObject]];
        [self.progressionNumbersArray addObject:[self.numbers lastObject]];
        for (int i = 0; i < self.operations.count; i++) {
            if([self calculateMultiplication:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]]){
                [self.operations removeObjectAtIndex:i];
                [self.numbers removeObjectAtIndex:i];
                self.numbers[i] = self.screenLabel.text;
                i--;
            }
        }
        
        for (int i = 0; i < self.operations.count; i++) {
            [self calculateAddition:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]];
            [self.operations removeObjectAtIndex:i];
            [self.numbers removeObjectAtIndex:i];
            self.numbers[i] = self.screenLabel.text;
            i--;
        }
    }
    
}
-(void)calculate {
    if(self.operations.count == 2){//definition is based on operations count for consistency
        if(self.numbers.count == 2 && [self calculateMultiplication:self.numbers operation:self.operations[0]]){
            [self calculated1Numbers];
        }
    }
    if(self.operations.count == 2){
        if([self.operations[1] isEqual:@"+"] ||
           [self.operations[1] isEqual:@"-"]){
            [self calculateAddition:@[self.numbers[0],self.numbers[1]] operation:self.operations[0]];
            [self calculated1Numbers];
        }
    }
    if(self.operations.count == 3 &&
       ([self.operations[2] isEqual:@"+"] ||
       [self.operations[2] isEqual:@"-"])){
        [self calculateMultiplication:@[self.numbers[1],self.numbers[2]] operation:self.operations[1]];
        [self calculateAddition:@[self.numbers[0], self.screenLabel.text] operation:self.operations[0]];
        NSString *operation = [self.operations lastObject];
        [self.operations removeAllObjects];
        [self.numbers removeAllObjects];
        [self.operations addObject:operation];
        [self.numbers addObject:self.screenLabel.text];
    }
    if(self.operations.count == 3 &&
       ([self.operations[2] isEqual:@"X"] ||
       [self.operations[2] isEqual:@"/"])){
        [self calculateMultiplication:@[self.numbers[1],self.numbers[2]] operation:self.operations[1]];
        [self.operations removeObjectAtIndex:1];
        [self.numbers removeLastObject];
        [self.numbers removeLastObject];
        [self.numbers addObject:self.screenLabel.text];
    }
}
- (void)resetFields {
    self.numbers = [NSMutableArray new];
    self.operations =[NSMutableArray new];
    self.progressionNumbersArray = [NSMutableArray new];
    self.progressionOperationsArray = [NSMutableArray new];
    self.isLastDigit = NO;
    self.isPlusMinus = NO;
    self.isProgression = NO;
    self.isPercentageProgression = NO;
}




- (IBAction)handleAC:(id)sender {
    UIButton *pressed = (UIButton *) sender;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
//    [self resetProgressionMode:pressed pressedText:pressedText];
    if([pressedText isEqualToString:@"AC"]){
        [self resetFields];
        self.screenLabel.text = @"0";
    }
    else {
        [pressed setTitle:@"AC" forState:UIControlStateNormal];
        if(self.isLastDigit){
            self.screenLabel.text = @"0";
        }
        else {
            [self.operations removeLastObject];
        }
    }
}

- (void)viewDidLoad {
    [self resetFields];
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

@end
/*-(void)calculateProgression {
    NSString *quotient;
    NSString *termN;
    if (self.progressionArray.count == 2) {
        quotient = self.progressionArray[0];
        termN = self.screenLabel.text;
    }
    else if (self.progressionArray.count == 3) {
        quotient = self.progressionArray[2];
        termN = self.progressionArray[0];
    }
    else if (self.progressionArray.count > 3) {//
        if(self.isProgression){
            quotient = self.progressionArray[2];
            termN = self.progressionArray[0];
            if ([self.progressionArray[3] isEqual:@"X"]) {
                termN = [self multiply:@[termN, quotient]];
            }
            else {
                termN = [self divide:@[termN, quotient]];
            }
        }
        else {
            quotient = self.progressionArray[2];
            termN = quotient;
            if (self.progressionArray.count == 4) {
            }
            else if (self.progressionArray.count == 5){
                double value = [self.progressionArray[4] doubleValue];
                value *= value;
                value /= 100;
                self.progressionArray[4] = [NSString stringWithFormat:@"%40.15g", value];
                NSLog(@"pv4 %f",value);
            }
        }
    }
    if(self.isProgression){
        if ([self.progressionArray[1] isEqual:@"+"]) {
            self.screenLabel.text = [self add:@[termN, quotient]];
        }
        else if ([self.progressionArray[1] isEqual:@"-"]) {
            self.screenLabel.text = [self subtract:@[termN, quotient]];
        }
        else if ([self.progressionArray[1] isEqual:@"X"]) {
            self.screenLabel.text = [self multiply:@[termN, quotient]];
        }
        else {
            self.screenLabel.text = [self divide:@[termN, quotient]];
        }
    }
    else {
        self.screenLabel.text = [self multiply:@[termN, quotient]];
        double value = [self.screenLabel.text doubleValue] / 100.0;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g", value];
    }
    if(self.progressionArray.count > 2){
        if(self.isProgression)
            self.progressionArray[0] = self.screenLabel.text;
        else
            self.progressionArray[2] = self.screenLabel.text;
    }
    if (self.progressionArray.count > 3 && self.isProgression) {
        self.progressionArray[1] = [[NSString alloc] initWithString:self.progressionArray.lastObject];
        [self.progressionArray removeLastObject];
    }
}*/

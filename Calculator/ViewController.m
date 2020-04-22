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

- (void)calculatePercentage {
    [self calculateMultiplication:@[self.screenLabel.text, @"100"] operation:@"/"];
    if (self.progressionOperationsArray.count > 0) {
        [self.progressionNumbersArray removeObjectAtIndex:0];
        [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
    }
    else {
        [self.numbers removeLastObject];
//        [self.numbers addObject:self.screenLabel.text];
        [self.operations removeLastObject];
    }
}

- (IBAction)handleOperations:(id)sender {//maybe i need a condition here to skip this part if i have a progression array
    UIButton *pressed = (UIButton *)sender;
    if(self.isLastDigit || self.isPlusMinus){
        [self.numbers addObject:self.screenLabel.text];
        [self.operations addObject:[pressed currentTitle]];
        [self calculate];
        if ([[pressed currentTitle] isEqual:@"%"] &&
            self.numbers.count == 1 && self.operations.count == 1){
            [self calculatePercentage];
            return;
        }
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        self.isLastDigit = NO;
        self.isPlusMinus = NO;
        if(!([[pressed currentTitle] isEqual:@"="] ||//kind of a miror condition of what is suggested, yet not efficient. check closely the situation needed for starting progression
             [[pressed currentTitle] isEqual:@"%"]))
            return;
        if ([[pressed currentTitle] isEqual:@"%"] && [self.operations[0] isEqual: [pressed currentTitle]]) {
            return;
        }
    }
    else if(self.numbers.count == 0){
        self.numbers[0] = @"0";
    }
    static NSString *progressionChanger;
    if([[pressed currentTitle] isEqual:@"="] ||
            [[pressed currentTitle] isEqual:@"%"]){
        //progression array should be ready when the number of operations is equal to or greater by 1 than the number of numbers. equal counted
        self.isLastDigit = NO;
        if(self.progressionNumbersArray.count > 0){//percentage progression equal pressed. meaning, end of percentage progression, maybe entry into regular progression check behavior
            if([self.progressionOperationsArray[0] isEqual:@"="] &&
               [[pressed currentTitle] isEqual:@"%"]){//situation of progression with % pressed
                [self calculatePercentage];
                return;
            }
        if(self.progressionNumbersArray.count > 0){//ending percentage progression
            if([self.progressionOperationsArray[0] isEqual:@"%"] &&
               [[pressed currentTitle] isEqual:@"="]){
                if(![self calculateMultiplication:self.progressionNumbersArray operation:self.operations[0]]){
                    [self calculateAddition:self.progressionNumbersArray operation:self.operations[0]];
                    self.progressionOperationsArray[0] = @"=";
                    [self.progressionNumbersArray removeLastObject];
                    [self.numbers removeLastObject];
                    [self.numbers addObject:self.screenLabel.text];
                    [self.progressionOperationsArray removeAllObjects];
                }//different regularity with +-X/
                return;
            }
        }
            NSString *progressNumber = [NSString stringWithString:[self.progressionNumbersArray lastObject]];
            BOOL isOperationContained = YES;//checking exit conditions regular progression
            for (int i = 0; i < self.operations.count && isOperationContained; i++) {
                if(![self.progressionOperationsArray containsObject:self.operations[i]]){
                    isOperationContained = NO;
                }
            }
            if(isOperationContained && [progressionChanger isEqual:progressNumber]){
                [self calculateProgressionNextTerm];
                self.numbers[self.numbers.count - 1] = self.screenLabel.text;
                return;

            }
            NSLog(@"reg nums while prog %@",self.numbers);//length 1
            NSLog(@"reg ops while prog %@",self.operations);//length 1
            NSLog(@"prog nums %@",self.progressionNumbersArray);
            NSLog(@"prog ops %@",self.progressionOperationsArray);
        }
        //[self.numbers addObject:self.screenLabel.text];
        //[self.operations addObject:[pressed currentTitle]];
        NSLog(@"nums calc %@",self.numbers);
        NSLog(@"nums ops %@",self.operations);
        progressionChanger = [self.numbers lastObject];
        [self calculateProgressionA1:[pressed currentTitle]];
    }
    else {//i think equal is the first member of progression array, here changes are made to storage arrays where it's the opposite the idea is that progressions can be reawakened
        [self.operations removeLastObject];
        [self.operations addObject:[pressed currentTitle]];
        NSLog(@"ops %@",self.operations);
        NSLog(@"nums %@",self.numbers);
    }
}

- (void)calculated1Numbers {//cleaning after simple running calculation
    NSLog(@"calculated1Numbers");
    [self.numbers removeAllObjects];
    [self.operations removeObjectAtIndex:0];
    [self.numbers addObject:self.screenLabel.text];
}

- (void)calculateTerm1Unary {//aXb a/b
    if(self.operations.count == 1){
        if(![self calculateMultiplication:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]]){
            [self calculateAddition:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]];
        }
    }
}

-(void)calculateProgressionA1:(NSString *)pressed{//actually the full percentage progression function... does not feel good
    NSString *operation = [NSString stringWithString:[self.operations lastObject]];
    NSString *number;
    if([pressed isEqual:@"%"] && self.progressionNumbersArray.count == 0){
        [self calculatePercentageA1];
        return;
    }
    else if([pressed isEqual:@"%"]){
        [self calculatePercentageNextTerm];
        return;
    }
    //first stage of regular progression
    //if last progression exists and desolving it. good?
    [self.progressionNumbersArray removeAllObjects];
    [self.progressionOperationsArray removeAllObjects];
    [self.progressionOperationsArray addObject: pressed];
    [self.operations removeObject:@"="];
    if (self.operations.count == 0) {
        [self.progressionOperationsArray removeAllObjects];
        return;
    }
    NSLog(@"ops %@ pops %@", self.operations, self.progressionOperationsArray);
    if(self.numbers.count == self.operations.count){
        operation = [NSString stringWithString:[self.operations lastObject]];
        number = [NSString stringWithString:[self.numbers lastObject]];
        [self.progressionOperationsArray addObject:operation];
        [self.progressionNumbersArray addObject:number];
        [self calculateTerm1Unary];
        if(self.operations.count == 2){//a+b= a*b=
            [self calculateMultiplication:@[self.numbers[0],self.numbers[1]] operation:self.operations[1]];
            [self calculateAddition:@[self.screenLabel.text, self.numbers[1]] operation:self.operations[0]];
        }
        [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
        return;//called from handleOperations
    }
    if(self.progressionNumbersArray.count == 0){//a+b* a+= a*= open ended
        [self.progressionOperationsArray addObject:[self.operations lastObject]];
        [self.progressionNumbersArray addObject:[self.numbers lastObject]];
        for (int i = 0; i < self.operations.count; i++) {//hasn't arrived the situations above, can be simplified simplification 1 resolving X/
            if([self calculateMultiplication:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]]){
                [self.operations removeObjectAtIndex:i];
                [self.numbers removeObjectAtIndex:i];
                self.numbers[i] = self.screenLabel.text;
                i--;
            }
        }
        
        for (int i = 0; i < self.operations.count; i++) {//hasn't arrived the situations above, can be simplified simplification 2 resolving +-
            [self calculateAddition:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]];
            [self.operations removeObjectAtIndex:i];
            [self.numbers removeObjectAtIndex:i];
            self.numbers[i] = self.screenLabel.text;
            i--;
        }
    }
    [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
}
-(void)calculatePercentageA1{
    NSString *operation = [NSString stringWithString:[self.operations lastObject]];

    //if last progression exists - dissolving
    [self.progressionNumbersArray removeAllObjects];
    [self.progressionOperationsArray removeAllObjects];
    [self.operations removeObject:@"%"];
    [self.progressionOperationsArray addObject:@"%"];
    [self.progressionOperationsArray addObject:operation];
    if (self.numbers.count == 1) {
        [self calculateMultiplication:@[self.numbers[0],self.numbers[0]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
        [self.progressionNumbersArray addObject:self.numbers[0]];
        [self.progressionNumbersArray addObject:self.screenLabel.text];
    }
    if (self.numbers.count == 2) {
        //self.isProgression = NO;
        [self calculateMultiplication:@[self.numbers[0],self.numbers[1]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
        [self.progressionNumbersArray addObject:self.numbers[0]];
        [self.progressionNumbersArray addObject:self.screenLabel.text];
    }
    if (self.numbers.count == 3) {
        self.isProgression = NO;
        [self calculateMultiplication:@[self.numbers[1],self.numbers[2]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
        [self.progressionNumbersArray addObject:self.numbers[1]];
        [self.progressionNumbersArray addObject:self.screenLabel.text];
    }
    
}
-(void)calculatePercentageNextTerm{
    if(self.numbers.count > 1){
        if(!self.isProgression){
            self.isProgression = YES;
            return;
        }
    }
    if(self.numbers.count > 1){
        [self calculateMultiplication:@[self.progressionNumbersArray[0],self.progressionNumbersArray[1]] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];

        self.progressionNumbersArray[1] = self.screenLabel.text;
        return;
    }
    //unary expression

    NSString *progNum2 = [[NSString alloc] initWithString:self.progressionNumbersArray[1]];
    self.progressionNumbersArray[0] = progNum2;
    [self calculateMultiplication:@[self.progressionNumbersArray[0],self.progressionNumbersArray[0]] operation:@"X"];
    [self calculateMultiplication:@[self.screenLabel.text,@"100"] operation:@"/"];
    self.progressionNumbersArray[1] = self.screenLabel.text;
    self.progressionNumbersArray[1] = self.screenLabel.text;
    
}
-(void)calculateProgressionNextTerm{
    NSLog(@"prog ops %@", self.progressionOperationsArray);
    if(![self calculateMultiplication:self.progressionNumbersArray operation:self.progressionOperationsArray[1]]){
        [self calculateAddition:self.progressionNumbersArray operation:self.progressionOperationsArray[1]];
    }
    [self.progressionNumbersArray removeObjectAtIndex:0];
    [self.progressionNumbersArray insertObject:self.screenLabel.text atIndex:0];
}
-(void)calculate {//junction switch to progression or not?
    if([[self.operations lastObject] isEqual:@"="] || [[self.operations lastObject] isEqual:@"%"]){
        return;
    }
    if([[self.operations lastObject] isEqual:@"%"]){
        [self calculatePercentageA1];
    }
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
// handleOperations -> calculate if progression is not looming:
//a, a+b a*b a+b+c a*b/c since everything but a is on the verge,
//this part might allow trickling to the next stage
//condition if self.operation.count <= self.numbers.count
//sub conditions if % = not pressed - calculate
//if pressed
//a= return isDigit = no, a is stored in numbers
//a+b= load to progressionArray send to calculate to send to progression
//back all the way and return. before getting to calculate pinch the last to
//progression array and leave calculate to simplify and enter a first term.
//and so on
//saved under commit: reorganization

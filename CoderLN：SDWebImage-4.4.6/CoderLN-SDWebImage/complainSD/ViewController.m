//
//  ViewController.m
//  CoderLN-SDWebImage
//


#import "ViewController.h"
#import "Teacher.h"
#import "Student.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     场景演练：
     现在有一个Teacher类表示班主任信息，包含姓名name属性和年龄age属性，另有一个Student类表示学生信息，也包含姓名name属性和年龄age属性。那么一个班包含一个班主任（Teacher对象）和n个学生（Student数组），为了统计一个班的信息，需要把班主任和学生的信息及对应关系保存下来。
     */
    //模拟NSMapTable提供的对象-->对象的映射关系
    Teacher *teacher = [[Teacher alloc] init];
    teacher.name = @"teacher";
    teacher.age = 30;
    NSMutableArray *aArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < 3; i++) {
        Student *student = [[Student alloc] init];
        student.name = [NSString stringWithFormat:@"student%d", i];
        student.age = i;
        [aArray addObject:student];
    }
    
    NSMapTable *aMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    [aMapTable setObject:aArray forKey:teacher];
    NSLog(@"%@", aMapTable);
 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  UploadParametersModel.h
//  NetRequest
//

#import <Foundation/Foundation.h>

@interface UploadParametersModel : NSObject

//  [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"picture%d",i] mimeType:@"image/png"];

@property (nonatomic, strong) NSData * fileData;// 上传的参数,二进制数据
@property (nonatomic, copy) NSString * name;// 服务器对应的参数名称; 二进制数据 @"file"、
@property (nonatomic, copy) NSString * fileName;// 文件上传到服务器保存名称
@property (nonatomic, copy) NSString * mimeType;// 文件的类型 (image/png,image/jpg等)




@end

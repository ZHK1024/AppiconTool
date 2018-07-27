//
//  main.m
//  Appicon
//
//  Created by ZHK on 2018/7/19.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


/**
 压缩图片到指定尺寸

 @param image 图片对象
 @param width 目标尺寸
 @return 压缩结果
 */
NSData * compressImage(NSImage *image, float width);

/**
 处理图片并把结果写入磁盘

 @param image 被处理的图片对象
 @param path  写入路径
 @param size  目标图片尺寸
 */
void writeImage(NSImage *image, NSString *path, float size);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *input = nil;
        NSString *output = nil;
        
        int ch;
        while ((ch = getopt(argc, argv, "i:o:")) != -1) {
            switch (ch) {
                case 'o':
                    output = [NSString stringWithUTF8String:optarg];
                    break;
                case 'i':
                    input = [NSString stringWithUTF8String:optarg];
                    break;
            }
        }
        
        BOOL isDir = NO;
        
        if (input && output && [[NSFileManager defaultManager] fileExistsAtPath:output isDirectory:&isDir]) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:input];
            if (image == nil) {
                printf("File Load Failed At %s", input.UTF8String);
                exit(0);
            }
            if (!isDir) {
                output = [output stringByAppendingPathComponent:@"icons"];
            }
            // 企业版
            writeImage(image, output, 512);
            writeImage(image, output, 57);
            // appstore
            writeImage(image, output, 180);
            writeImage(image, output, 120);
            writeImage(image, output, 80);
            writeImage(image, output, 60);
            writeImage(image, output, 40);
        } else {
            printf("Path Error!\n");
        }
    }
    return 0;
}


NSData * compressImage(NSImage *image, float width) {
    NSData *data = image.TIFFRepresentation;
    if (data == nil) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
//    NSRect rect = NSMakeRect(0, 0, width, width);
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgimage];
    rep.size = CGSizeMake(width, width);
    NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
//    NSImage *newImage = [[NSImage alloc] initWithSize:rect.size];
//    [newImage lockFocus];
//    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//    CGContextDrawImage(context, rect, cgimage);
//    [newImage unlockFocus];
    
    return pngData;
}

void writeImage(NSImage *image, NSString *path, float size) {
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.png", size]];
    [compressImage(image, size) writeToFile:path atomically:NO];
}

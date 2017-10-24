//
//  AppsFlyerXAppleHelper.m
//  AppsFlyerCocos2dX
//
//  Created by Andrey Gagan on 10/5/17.
//  AppsFlyer

#include "AppsFlyerXAppleHelper.h"

ValueMap AppsFlyerXAppleHelper::nsDictionary2ValueMap(NSDictionary *dic) {
    ValueMap vm;
    nsDictionary2ValueMap(dic, vm);
    return vm;
}

void AppsFlyerXAppleHelper::nsDictionary2ValueMap(NSDictionary *dic, ValueMap &vm) {
    NSArray *keys = [dic allKeys];
    for (NSString *k : keys) {
        id obj = dic[k];
        std::string key([k cStringUsingEncoding:NSUTF8StringEncoding]);
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            //Dictionary
            ValueMap vmm;
            nsDictionary2ValueMap((NSDictionary *) obj, vmm);
            vm[key] = vmm;
        } else if ([obj isKindOfClass:[NSArray class]]) {
            //Array
            ValueVector vv;
            nsArray2ValueVector((NSArray *) obj, vv);
            vm[key] = vv;
        } else if ([obj isKindOfClass:[NSString class]]) {
            //String
            vm[key] = [(NSString *) obj cStringUsingEncoding:NSUTF8StringEncoding];
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            //Number
            vm[key] = [[(NSNumber *)obj stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"%s - Non supported type %@", __FUNCTION__, [obj class]);
        }
    }
}

ValueVector AppsFlyerXAppleHelper::nsArray2ValueVector(NSArray *array) {
    ValueVector vv;
    nsArray2ValueVector(array, vv);
    return vv;
}

void AppsFlyerXAppleHelper::nsArray2ValueVector(NSArray *array, ValueVector &vv) {
    for (id obj : array) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            //Dictionary
            ValueMap vm;
            nsDictionary2ValueMap((NSDictionary *) obj, vm);
            vv.push_back(Value(vm));
        } else if ([obj isKindOfClass:[NSArray class]]) {
            //Array
            ValueVector vvv;
            nsArray2ValueVector((NSArray *) obj, vvv);
            vv.push_back(Value(vvv));
        } else if ([obj isKindOfClass:[NSString class]]) {
            //String
            vv.push_back(Value([(NSString *)obj cStringUsingEncoding:NSUTF8StringEncoding]));
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            //Number
            vv.push_back(Value([obj stringValue]));
        } else {
            NSLog(@"%s - Non supported type %@", __FUNCTION__, [obj class]);
        }
    }
}

NSDictionary *AppsFlyerXAppleHelper::valueMap2nsDictionary(ValueMap &vm) {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (auto i : vm) {
        NSString *key = [NSString stringWithUTF8String:i.first.c_str()];
        switch (i.second.getType()) {
            case Value::Type::MAP:
                dic[key] = valueMap2nsDictionary(i.second.asValueMap());
                break;
                
            case Value::Type::VECTOR:
                dic[key] = valueVector2nsArray(i.second.asValueVector());
                break;
                
            default:
            {   if([key isEqualToString:@"some_test_remove_it"])
            {
                NSString* pngPath = [NSString stringWithUTF8String:i.second.asString().c_str()];
                UIImage *image = [UIImage imageWithContentsOfFile:pngPath];
                NSData *data = UIImagePNGRepresentation(image);
                dic[key] = data;
                
            }
            else
            {
                dic[key] = [NSString stringWithUTF8String:i.second.asString().c_str()];
            }
                break;
            }
        }
    }
    return dic;
}

NSArray *AppsFlyerXAppleHelper::valueVector2nsArray(ValueVector &vv) {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:vv.size()];
    for (auto i : vv) {
        switch (i.getType()) {
            case Value::Type::MAP:
                [array addObject:valueMap2nsDictionary(i.asValueMap())];
                break;
            case Value::Type::VECTOR:
                [array addObject:valueVector2nsArray(i.asValueVector())];
                break;
            default:
                [array addObject:[NSString stringWithUTF8String:i.asString().c_str()]];
                break;
        }
    }
    return array;
}
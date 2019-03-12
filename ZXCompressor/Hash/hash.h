//
//  hash.h
//  https://blog.csdn.net/liuaigui/article/details/5050697
//

#ifndef hash_h
#define hash_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    /* A Simple Hash Function */
    unsigned int simple_hash(const char *str, unsigned int len);
    
    /* RS Hash Function */
    unsigned int RS_hash(const char *str, unsigned int len);
    
    /* JS Hash Function */
    unsigned int JS_hash(const char *str, unsigned int len);
    
    /* P. J. Weinberger Hash Function */
    unsigned int PJW_hash(const char *str, unsigned int len);
    
    /* ELF Hash Function */
    unsigned int ELF_hash(const char *str, unsigned int len);
    
    /* BKDR Hash Function */
    unsigned int BKDR_hash(const char *str, unsigned int len);
    
    /* SDBM Hash Function */
    unsigned int SDBM_hash(const char *str, unsigned int len);
    
    /* DJB Hash Function */
    unsigned int DJB_hash(const char *str, unsigned int len);
    
    /* AP Hash Function */
    unsigned int AP_hash(const char *str, unsigned int len);
    
    /* CRC Hash Function */
    unsigned int CRC_hash(const char *str, unsigned int len);
    
#ifdef __cplusplus
}
#endif

#endif /* hash_h */

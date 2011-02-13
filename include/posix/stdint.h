////////////////////////////////////////////////////////////////////////////////
// File: stdint.h
// Copyright (c) 2011, Artur Wyszyński <harakash@gmail.com>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of Artur Wyszyński nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////

#ifndef _STDINT_H
#define _STDINT_H

#include <null.h>

// exact-width integer types
typedef signed char         int8_t;
typedef unsigned char       uint8_t;
typedef signed short        int16_t;
typedef unsigned short      uint16_t;
typedef signed int          int32_t;
typedef unsigned int        uint32_t;
typedef signed long long    int64_t;
typedef unsigned long long  uint64_t;

// minimum-width integer types
typedef int8_t              int_least8_t;
typedef uint8_t             uint_least8_t;
typedef int16_t             int_least16_t;
typedef uint16_t            uint_least16_t;
typedef int32_t             int_least32_t;
typedef uint32_t            uint_least32_t;
typedef int64_t             int_least64_t;
typedef uint64_t            uint_least64_t;

// fastest minimum-width integer types
typedef int32_t             int_fast8_t;
typedef uint32_t            uint_fast8_t;
typedef int32_t             int_fast16_t;
typedef uint32_t            uint_fast16_t;
typedef int32_t             int_fast32_t;
typedef uint32_t            uint_fast32_t;
typedef int64_t             int_fast64_t;
typedef uint64_t            uint_fast64_t;

typedef int32_t             saddr_t;
typedef uint32_t            addr_t;

// integer types capable of holding object pointers
typedef saddr_t             intptr_t;
typedef addr_t              uintptr_t;

// greatest-width integer types
typedef int64_t             intmax_t;
typedef uint64_t            uintmax_t;

#define SADDR_MAX           (2147483647)
#define SADDR_MIN           (-SADDR_MAX-1)
#define ADDR_MAX            (4294967295U)

// limits of exact-width integer types
#define INT8_MIN            (-128)
#define INT8_MAX            (127)
#define UINT8_MAX           (255U)

#define INT16_MIN           (-32768)
#define INT16_MAX           (32767)
#define UINT16_MAX          (65535U)

#define INT32_MAX           (2147483647)
#define INT32_MIN           (-INT32_MAX-1)
#define UINT32_MAX          (4294967295U)

#define INT64_MAX           (9223372036854775807LL)
#define INT64_MIN           (-INT64_MAX-1)
#define UINT64_MAX          (18446744073709551615ULL)

// limits of minimum-width integer types
#define INT_LEAST8_MIN      INT8_MIN
#define INT_LEAST8_MAX      INT8_MAX
#define UINT_LEAST8_MAX     UINT8_MAX

#define INT_LEAST16_MIN     INT16_MIN
#define INT_LEAST16_MAX     INT16_MAX
#define UINT_LEAST16_MAX    UINT16_MAX

#define INT_LEAST32_MIN     INT32_MIN
#define INT_LEAST32_MAX     INT32_MAX
#define UINT_LEAST32_MAX    UINT32_MAX

#define INT_LEAST64_MIN     INT64_MIN
#define INT_LEAST64_MAX     INT64_MAX
#define UINT_LEAST64_MAX    UINT64_MAX

// limits of fastest minimum-width integer types
#define INT_FAST8_MIN       INT8_MIN
#define INT_FAST8_MAX       INT8_MAX
#define UINT_FAST8_MAX      UINT8_MAX

#define INT_FAST16_MIN      INT16_MIN
#define INT_FAST16_MAX      INT16_MAX
#define UINT_FAST16_MAX     UINT16_MAX

#define INT_FAST32_MIN      INT32_MIN
#define INT_FAST32_MAX      INT32_MAX
#define UINT_FAST32_MAX     UINT32_MAX

#define INT_FAST64_MIN      INT64_MIN
#define INT_FAST64_MAX      INT64_MAX
#define UINT_FAST64_MAX     UINT64_MAX

// limits of integer types capable of holding object pointers
#define INTPTR_MIN          SADDR_MIN
#define INTPTR_MAX          SADDR_MAX
#define UINTPTR_MAX         ADDR_MAX

// limits of greatest-width integer types
#define INTMAX_MIN          INT64_MIN
#define INTMAX_MAX          INT64_MAX
#define UINTMAX_MAX         UINT64_MAX

// limits of other integer types
#define PTDIFF_MIN          SADDR_MIN
#define PTDIFF_MAX          SADDR_MAX

#define SIG_ATOMIC_MIN      INT32_MIN
#define SIG_ATOMIC_MAX      INT32_MAX

#define SIZE_MAX            ADDR_MAX

#define WINT_MIN            0
#define WINT_MAX            ((wint_t)-1)

#if !defined(__cplusplus) || defined(__STDC_CONSTANT_MACROS)

// macros of integer constant expressions
#define INT8_C(value)       value
#define INT16_C(value)      value
#define INT32_C(value)      value
#define INT64_C(value)      value ## LL

#define UINT8_C(value)      value ## U
#define UINT16_C(value)     value ## U
#define UINT32_C(value)     value ## U
#define UINT64_C(value)     value ## ULL

// macros for greatest-width integer constant expressions
#define INTMAX_C(value)     value ## LL
#define UINTMAX_C(value)    value ## ULL

#endif // !defined(__cplusplus) || defined(__STDC_CONSTANT_MACROS)

#endif // _STDINT_H

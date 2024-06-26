# Copyright (C) 2019 Intel Corporation.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

.text
.align 2
.globl invokeNative
invokeNative:

    # %rcx func_ptr
    # %rdx argv
    # %r8 n_stacks

    push %rbp
    mov %rsp, %rbp

    mov %rcx, %r10    # func_ptr
    mov %rdx, %rax    # argv
    mov %r8, %rcx     # n_stacks

    # fill all fp args
    movsd 0(%rax), %xmm0
    movsd 8(%rax), %xmm1
    movsd 16(%rax), %xmm2
    movsd 24(%rax), %xmm3

    # check for stack args
    cmp $0, %rcx
    jz cycle_end

    mov %rsp, %rdx
    and $15, %rdx
    jz no_abort
    int $3
no_abort:
    mov %rcx, %rdx
    and $1, %rdx
    shl $3, %rdx
    sub %rdx, %rsp

    # store stack args
    lea 56(%rax, %rcx, 8), %r9
    sub %rsp, %r9                   # offset
cycle:
    push (%rsp, %r9)
    loop cycle

cycle_end:
    mov 0x40(%rax), %rcx
    mov 0x48(%rax), %rdx
    mov 0x50(%rax), %r8
    mov 0x58(%rax), %r9

    sub $32, %rsp # shadow space

    call *%r10
    leave
    ret

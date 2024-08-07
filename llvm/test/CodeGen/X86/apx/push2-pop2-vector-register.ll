; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; Check PUSH2/POP2 is not used for vector registers
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc -mattr=+push2pop2 | FileCheck %s --check-prefix=CHECK
; RUN: llc < %s -mtriple=x86_64-pc-windows-msvc -mattr=+push2pop2 -frame-pointer=all | FileCheck %s --check-prefix=FRAME

define void @widget(float %arg) nounwind {
; CHECK-LABEL: widget:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    pushq %r15
; CHECK-NEXT:    push2 %rbp, %rsi
; CHECK-NEXT:    subq $48, %rsp
; CHECK-NEXT:    movaps %xmm6, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; CHECK-NEXT:    movaps %xmm0, %xmm6
; CHECK-NEXT:    xorl %esi, %esi
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    callq *%rsi
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    xorl %r8d, %r8d
; CHECK-NEXT:    callq *%rsi
; CHECK-NEXT:    movss %xmm6, 0
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm6 # 16-byte Reload
; CHECK-NEXT:    addq $48, %rsp
; CHECK-NEXT:    pop2 %rsi, %rbp
; CHECK-NEXT:    popq %r15
; CHECK-NEXT:    retq
;
; FRAME-LABEL: widget:
; FRAME:       # %bb.0: # %bb
; FRAME-NEXT:    pushq %rbp
; FRAME-NEXT:    push2 %rsi, %r15
; FRAME-NEXT:    subq $48, %rsp
; FRAME-NEXT:    leaq {{[0-9]+}}(%rsp), %rbp
; FRAME-NEXT:    movaps %xmm6, {{[-0-9]+}}(%r{{[sb]}}p) # 16-byte Spill
; FRAME-NEXT:    movaps %xmm0, %xmm6
; FRAME-NEXT:    xorl %esi, %esi
; FRAME-NEXT:    xorl %ecx, %ecx
; FRAME-NEXT:    callq *%rsi
; FRAME-NEXT:    xorl %ecx, %ecx
; FRAME-NEXT:    xorl %edx, %edx
; FRAME-NEXT:    xorl %r8d, %r8d
; FRAME-NEXT:    callq *%rsi
; FRAME-NEXT:    movss %xmm6, 0
; FRAME-NEXT:    pushq %rbp
; FRAME-NEXT:    pushq %rax
; FRAME-NEXT:    #APP
; FRAME-NEXT:    #NO_APP
; FRAME-NEXT:    popq %rax
; FRAME-NEXT:    popq %rbp
; FRAME-NEXT:    movaps {{[-0-9]+}}(%r{{[sb]}}p), %xmm6 # 16-byte Reload
; FRAME-NEXT:    addq $48, %rsp
; FRAME-NEXT:    pop2 %r15, %rsi
; FRAME-NEXT:    popq %rbp
; FRAME-NEXT:    retq
bb:
  %call = tail call float null(ptr null)
  %call1 = tail call i32 null(ptr null, i32 0, i32 0)
  store float %arg, ptr null, align 4
  tail call void asm sideeffect "", "~{rbp},~{r15},~{dirflag},~{fpsr},~{flags}"()
  ret void
}

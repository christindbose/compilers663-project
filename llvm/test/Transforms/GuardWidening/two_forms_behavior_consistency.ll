; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 2
; RUN: opt -S -passes="guard-widening,make-guards-explicit,simplifycfg" < %s        | FileCheck %s --check-prefixes=INTRINSIC_FORM
; RUN: opt -S -passes="make-guards-explicit,guard-widening,simplifycfg" < %s        | FileCheck %s --check-prefixes=BRANCH_FORM
; RUN: opt -S -passes="make-guards-explicit,loop-mssa(licm),guard-widening,simplifycfg" < %s        | FileCheck %s --check-prefixes=BRANCH_FORM_LICM

declare i1 @cond() readonly

; FIXME We want to make sure that guard widening works in the same way, no matter what form of
;       guards it is dealing with.
; We also want to make sure that LICM doesn't mess with widenable conditions, what might
; make things more complex.

define void @test_01(i32 %a, i32 %b, i32 %c, i32 %d) {
; INTRINSIC_FORM-LABEL: define void @test_01
; INTRINSIC_FORM-SAME: (i32 [[A:%.*]], i32 [[B:%.*]], i32 [[C:%.*]], i32 [[D:%.*]]) {
; INTRINSIC_FORM-NEXT:  entry:
; INTRINSIC_FORM-NEXT:    br label [[LOOP:%.*]]
; INTRINSIC_FORM:       loop:
; INTRINSIC_FORM-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[GUARDED:%.*]] ]
; INTRINSIC_FORM-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; INTRINSIC_FORM-NEXT:    [[C1:%.*]] = icmp ult i32 [[IV]], [[A]]
; INTRINSIC_FORM-NEXT:    [[C2:%.*]] = icmp ult i32 [[IV]], [[B]]
; INTRINSIC_FORM-NEXT:    [[WIDE_CHK:%.*]] = and i1 [[C1]], [[C2]]
; INTRINSIC_FORM-NEXT:    [[C3:%.*]] = icmp ult i32 [[IV]], [[C]]
; INTRINSIC_FORM-NEXT:    [[WIDE_CHK1:%.*]] = and i1 [[WIDE_CHK]], [[C3]]
; INTRINSIC_FORM-NEXT:    [[C4:%.*]] = icmp ult i32 [[IV]], [[D]]
; INTRINSIC_FORM-NEXT:    [[WIDE_CHK2:%.*]] = and i1 [[WIDE_CHK1]], [[C4]]
; INTRINSIC_FORM-NEXT:    [[WIDENABLE_COND:%.*]] = call i1 @llvm.experimental.widenable.condition()
; INTRINSIC_FORM-NEXT:    [[EXIPLICIT_GUARD_COND:%.*]] = and i1 [[WIDE_CHK2]], [[WIDENABLE_COND]]
; INTRINSIC_FORM-NEXT:    br i1 [[EXIPLICIT_GUARD_COND]], label [[GUARDED]], label [[DEOPT:%.*]], !prof [[PROF0:![0-9]+]]
; INTRINSIC_FORM:       deopt:
; INTRINSIC_FORM-NEXT:    call void (...) @llvm.experimental.deoptimize.isVoid() [ "deopt"() ]
; INTRINSIC_FORM-NEXT:    ret void
; INTRINSIC_FORM:       guarded:
; INTRINSIC_FORM-NEXT:    [[LOOP_COND:%.*]] = call i1 @cond()
; INTRINSIC_FORM-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; INTRINSIC_FORM:       exit:
; INTRINSIC_FORM-NEXT:    ret void
;
; BRANCH_FORM-LABEL: define void @test_01
; BRANCH_FORM-SAME: (i32 [[A:%.*]], i32 [[B:%.*]], i32 [[C:%.*]], i32 [[D:%.*]]) {
; BRANCH_FORM-NEXT:  entry:
; BRANCH_FORM-NEXT:    br label [[LOOP:%.*]]
; BRANCH_FORM:       loop:
; BRANCH_FORM-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[GUARDED5:%.*]] ]
; BRANCH_FORM-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; BRANCH_FORM-NEXT:    [[C1:%.*]] = icmp ult i32 [[IV]], [[A]]
; BRANCH_FORM-NEXT:    [[C2:%.*]] = icmp ult i32 [[IV]], [[B]]
; BRANCH_FORM-NEXT:    [[WIDE_CHK:%.*]] = and i1 [[C1]], [[C2]]
; BRANCH_FORM-NEXT:    [[WIDENABLE_COND:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM-NEXT:    [[EXIPLICIT_GUARD_COND:%.*]] = and i1 [[WIDE_CHK]], [[WIDENABLE_COND]]
; BRANCH_FORM-NEXT:    br i1 [[EXIPLICIT_GUARD_COND]], label [[GUARDED:%.*]], label [[DEOPT:%.*]], !prof [[PROF0:![0-9]+]]
; BRANCH_FORM:       deopt:
; BRANCH_FORM-NEXT:    call void (...) @llvm.experimental.deoptimize.isVoid() [ "deopt"() ]
; BRANCH_FORM-NEXT:    ret void
; BRANCH_FORM:       guarded:
; BRANCH_FORM-NEXT:    [[WIDENABLE_COND3:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM-NEXT:    [[EXIPLICIT_GUARD_COND4:%.*]] = and i1 [[C2]], [[WIDENABLE_COND3]]
; BRANCH_FORM-NEXT:    [[C3:%.*]] = icmp ult i32 [[IV]], [[C]]
; BRANCH_FORM-NEXT:    [[C4:%.*]] = icmp ult i32 [[IV]], [[D]]
; BRANCH_FORM-NEXT:    [[WIDE_CHK13:%.*]] = and i1 [[C3]], [[C4]]
; BRANCH_FORM-NEXT:    [[WIDENABLE_COND7:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM-NEXT:    [[EXIPLICIT_GUARD_COND8:%.*]] = and i1 [[WIDE_CHK13]], [[WIDENABLE_COND7]]
; BRANCH_FORM-NEXT:    br i1 [[EXIPLICIT_GUARD_COND8]], label [[GUARDED5]], label [[DEOPT6:%.*]], !prof [[PROF0]]
; BRANCH_FORM:       deopt6:
; BRANCH_FORM-NEXT:    call void (...) @llvm.experimental.deoptimize.isVoid() [ "deopt"() ]
; BRANCH_FORM-NEXT:    ret void
; BRANCH_FORM:       guarded5:
; BRANCH_FORM-NEXT:    [[WIDENABLE_COND11:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM-NEXT:    [[EXIPLICIT_GUARD_COND12:%.*]] = and i1 [[C4]], [[WIDENABLE_COND11]]
; BRANCH_FORM-NEXT:    [[LOOP_COND:%.*]] = call i1 @cond()
; BRANCH_FORM-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; BRANCH_FORM:       exit:
; BRANCH_FORM-NEXT:    ret void
;
; BRANCH_FORM_LICM-LABEL: define void @test_01
; BRANCH_FORM_LICM-SAME: (i32 [[A:%.*]], i32 [[B:%.*]], i32 [[C:%.*]], i32 [[D:%.*]]) {
; BRANCH_FORM_LICM-NEXT:  entry:
; BRANCH_FORM_LICM-NEXT:    br label [[LOOP:%.*]]
; BRANCH_FORM_LICM:       loop:
; BRANCH_FORM_LICM-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[GUARDED5:%.*]] ]
; BRANCH_FORM_LICM-NEXT:    [[IV_NEXT]] = add i32 [[IV]], 1
; BRANCH_FORM_LICM-NEXT:    [[C1:%.*]] = icmp ult i32 [[IV]], [[A]]
; BRANCH_FORM_LICM-NEXT:    [[C2:%.*]] = icmp ult i32 [[IV]], [[B]]
; BRANCH_FORM_LICM-NEXT:    [[WIDE_CHK:%.*]] = and i1 [[C1]], [[C2]]
; BRANCH_FORM_LICM-NEXT:    [[WIDENABLE_COND:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM_LICM-NEXT:    [[EXIPLICIT_GUARD_COND:%.*]] = and i1 [[WIDE_CHK]], [[WIDENABLE_COND]]
; BRANCH_FORM_LICM-NEXT:    br i1 [[EXIPLICIT_GUARD_COND]], label [[GUARDED:%.*]], label [[DEOPT:%.*]], !prof [[PROF0:![0-9]+]]
; BRANCH_FORM_LICM:       deopt:
; BRANCH_FORM_LICM-NEXT:    call void (...) @llvm.experimental.deoptimize.isVoid() [ "deopt"() ]
; BRANCH_FORM_LICM-NEXT:    ret void
; BRANCH_FORM_LICM:       guarded:
; BRANCH_FORM_LICM-NEXT:    [[WIDENABLE_COND3:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM_LICM-NEXT:    [[EXIPLICIT_GUARD_COND4:%.*]] = and i1 [[C2]], [[WIDENABLE_COND3]]
; BRANCH_FORM_LICM-NEXT:    [[C3:%.*]] = icmp ult i32 [[IV]], [[C]]
; BRANCH_FORM_LICM-NEXT:    [[C4:%.*]] = icmp ult i32 [[IV]], [[D]]
; BRANCH_FORM_LICM-NEXT:    [[WIDE_CHK13:%.*]] = and i1 [[C3]], [[C4]]
; BRANCH_FORM_LICM-NEXT:    [[WIDENABLE_COND7:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM_LICM-NEXT:    [[EXIPLICIT_GUARD_COND8:%.*]] = and i1 [[WIDE_CHK13]], [[WIDENABLE_COND7]]
; BRANCH_FORM_LICM-NEXT:    br i1 [[EXIPLICIT_GUARD_COND8]], label [[GUARDED5]], label [[DEOPT6:%.*]], !prof [[PROF0]]
; BRANCH_FORM_LICM:       deopt6:
; BRANCH_FORM_LICM-NEXT:    call void (...) @llvm.experimental.deoptimize.isVoid() [ "deopt"() ]
; BRANCH_FORM_LICM-NEXT:    ret void
; BRANCH_FORM_LICM:       guarded5:
; BRANCH_FORM_LICM-NEXT:    [[WIDENABLE_COND11:%.*]] = call i1 @llvm.experimental.widenable.condition()
; BRANCH_FORM_LICM-NEXT:    [[EXIPLICIT_GUARD_COND12:%.*]] = and i1 [[C4]], [[WIDENABLE_COND11]]
; BRANCH_FORM_LICM-NEXT:    [[LOOP_COND:%.*]] = call i1 @cond()
; BRANCH_FORM_LICM-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT:%.*]]
; BRANCH_FORM_LICM:       exit:
; BRANCH_FORM_LICM-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i32 [0, %entry], [%iv.next, %loop]
  %iv.next = add i32 %iv, 1
  %c1 = icmp ult i32 %iv, %a
  call void(i1, ...) @llvm.experimental.guard(i1 %c1) [ "deopt"() ]
  %c2 = icmp ult i32 %iv, %b
  call void(i1, ...) @llvm.experimental.guard(i1 %c2) [ "deopt"() ]
  %c3 = icmp ult i32 %iv, %c
  call void(i1, ...) @llvm.experimental.guard(i1 %c3) [ "deopt"() ]
  %c4 = icmp ult i32 %iv, %d
  call void(i1, ...) @llvm.experimental.guard(i1 %c4) [ "deopt"() ]
  %loop_cond = call i1 @cond()
  br i1 %loop_cond, label %loop, label %exit

exit:
  ret void
}

declare void @llvm.experimental.guard(i1, ...)

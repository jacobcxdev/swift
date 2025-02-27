// RUN: %target-typecheck-verify-swift -dump-requirement-machine -disable-requirement-machine-merged-associated-types 2>&1 | %FileCheck %s

protocol P1 {
  associatedtype T : P1
}

protocol P2 {
  associatedtype T where T == Int
}

extension Int : P1 {
  public typealias T = Int
}

struct G<T : P1 & P2> {}

// Since G.T.T == G.T.T.T == G.T.T.T.T = ... = Int, we tie off the
// recursion by introducing a same-type requirement G.T.T => G.T.

// CHECK-LABEL: Adding generic signature <τ_0_0 where τ_0_0 : P1, τ_0_0 : P2> {
// CHECK-LABEL: Rewrite system: {
// CHECK: - [P1:T].T => [P1:T].[P1:T]
// CHECK: - τ_0_0.[P1:T].[concrete: Int] => τ_0_0.[P1:T]
// CHECK: - τ_0_0.[P1:T].[P1:T] => τ_0_0.[P1:T]
// CHECK: }
// CHECK: }

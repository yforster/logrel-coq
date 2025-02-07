(** * LogRel.NormalForms: definition of normal and neutral forms, and properties. *)
From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst Context.

(** ** Weak-head normal forms and neutrals. *)

Inductive whnf : term -> Type :=
  | whnf_tSort {s} : whnf (tSort s)
  | whnf_tProd {na A B} : whnf (tProd na A B)
  | whnf_tLambda {na A t} : whnf (tLambda na A t)
  | whnf_tNat : whnf tNat
  | whnf_tZero : whnf tZero
  | whnf_tSucc {n} : whnf (tSucc n)
  | whnf_whne {n} : whne n -> whnf n
with whne : term -> Type :=
  | whne_tRel {v} : whne (tRel v)
  | whne_tApp {n t} : whne n -> whne (tApp n t)
  | whne_tNatElim {P hz hs n} : whne n -> whne (tNatElim P hz hs n).

#[global] Hint Constructors whne whnf : gen_typing.

Ltac inv_whne :=
  repeat lazymatch goal with
    | H : whne _ |- _ =>
    try solve [inversion H] ; block H
  end; unblock.

Lemma neSort s : whne (tSort s) -> False.
Proof.
  inversion 1.
Qed.

Lemma nePi na A B : whne (tProd na A B) -> False.
Proof.
  inversion 1.
Qed.

Lemma neLambda na A t : whne (tLambda na A t) -> False.
Proof.
  inversion 1.
Qed.

#[global] Hint Resolve neSort nePi neLambda : gen_typing.

(** ** Restricted classes of normal forms *)

Inductive isType : term -> Type :=
  | UnivType {s} : isType (tSort s)
  | ProdType {na A B} : isType (tProd na A B)
  | NatType : isType tNat
  | NeType {A}  : whne A -> isType A.

Inductive isPosType : term -> Type :=
  | UnivPos {s} : isPosType (tSort s)
  | NatPos : isPosType tNat
  | NePos {A}  : whne A -> isPosType A.

Inductive isFun : term -> Type :=
  | LamFun {na A t} : isFun (tLambda na A t)
  | NeFun  {f} : whne f -> isFun f.

Definition isPosType_isType t (i : isPosType t) : isType t :=
  match i with
    | UnivPos => UnivType
    | NatPos => NatType
    | NePos ne => NeType ne
  end.

Coercion isPosType_isType : isPosType >-> isType.

Definition isType_whnf t (i : isType t) : whnf t :=
  match i with
    | UnivType => whnf_tSort
    | ProdType => whnf_tProd
    | NatType => whnf_tNat
    | NeType ne => whnf_whne ne
  end.

Coercion isType_whnf : isType >-> whnf.

Definition isFun_whnf t (i : isFun t) : whnf t :=
  match i with
    | LamFun => whnf_tLambda
    | NeFun ne => whnf_whne ne
  end.

Coercion isFun_whnf : isFun >-> whnf.

#[global] Hint Resolve isPosType_isType isType_whnf isFun_whnf : gen_typing.
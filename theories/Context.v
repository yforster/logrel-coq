(** * LogRel.Context: definition of contexts and operations on them.*)
From Coq Require Import ssreflect Morphisms Setoid.
From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst.

Set Primitive Projections.

(** ** Context declaration *)

(** The name is just a printing annotation: terms use de Bruijn indices to refer to context entries.*)

Record context_decl := mkdecl {
  decl_name : aname ;
  decl_type : term
}.

Definition map_decl (f : term -> term) : context_decl -> context_decl :=
  fun d => {| decl_name := d.(decl_name) ; decl_type := f d.(decl_type) |}.

Lemma map_decl_id (f : term -> term) : f =1 id -> map_decl f =1 id.
Proof.
  intros Hf [a t].
  cbv.
  f_equal.
  now apply Hf.
Qed.

Lemma compose_map_decl f g x :
  map_decl f (map_decl g x) = map_decl (g >> f) x.
Proof.
  destruct x; reflexivity.
Qed.

Lemma map_decl_ext f g x : (forall x, f x = g x) -> map_decl f x = map_decl g x.
Proof.
  intros H; destruct x; rewrite /map_decl /=; f_equal; auto.
Qed.

#[global] Instance map_decl_proper : Proper (`=1` ==> Logic.eq ==> Logic.eq) map_decl.
Proof.
  intros f g Hfg x y ->. now apply map_decl_ext.
Qed.

#[global] Instance map_decl_pointwise : Proper (`=1` ==> `=1`) map_decl.
Proof. intros f g Hfg x. rewrite /map_decl.
  destruct x => /=. f_equal.
  now rewrite Hfg.
Qed.

Arguments map_decl _ !_/.

#[global] Instance Ren_decl : (Ren1 (nat -> nat) context_decl context_decl) :=
  fun ρ t => map_decl (ren_term ρ) t.

Arguments Ren_decl _ !_/.

Ltac fold_ren_decl := change Ren_decl with ren1 in *.
Smpl Add fold_ren_decl : refold.

Definition vass a A := {| decl_name := a ; decl_type := A |}.

(** ** Context: list of declarations *)

Definition context := list context_decl.

Notation "'ε'" := (@nil context_decl).
Notation " Γ ,, d " := (@cons context_decl d Γ) (at level 20, d at next level).
Notation " Γ ,,, Δ " := (@app context_decl Δ Γ) (at level 25, Δ at next level, left associativity).

(** States that a definition, correctly weakened, is in a context. *)
Inductive in_ctx : context -> nat -> context_decl -> Type :=
  | in_here (Γ : context) d : in_ctx (Γ,,d) 0 (d⟨↑⟩)
  | in_there (Γ : context) d d' n : in_ctx Γ n d -> in_ctx (Γ,,d') (S n) (map_decl (ren_term shift) d).

Lemma in_ctx_inj Γ n decl decl' :
  in_ctx Γ n decl -> in_ctx Γ n decl' -> decl = decl'.
Proof.
  induction 1 in decl' |- * ; inversion 1 ; subst.
  1: reflexivity.
  now f_equal.
Qed.
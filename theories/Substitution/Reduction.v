From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst Notations Context NormalForms Weakening GenericTyping LogicalRelation DeclarativeInstance Validity.
From LogRel.LogicalRelation Require Import Irrelevance Escape Reflexivity Weakening Neutral Reduction Transitivity.

Set Universe Polymorphism.

Section Reduction.
Context `{GenericTypingProperties}.

Set Printing Primitive Projection Parameters.

Lemma redwfSubstValid {Γ A t u l}
  (VΓ : [||-v Γ])
  (red : [Γ ||-v t :⇒*: u : A | VΓ])
  (VA : [Γ ||-v<l> A | VΓ])
  (Vu : [Γ ||-v<l> u : A | VΓ | VA]) :
  [Γ ||-v<l> t : A | VΓ | VA] × [Γ ||-v<l> t ≅ u : A | VΓ | VA].
Proof.
  assert (Veq : [Γ ||-v<l> t ≅ u : A | VΓ | VA]).
  {
    constructor; intros; eapply redwfSubstTerm.
    1: now eapply validTm.
    now eapply validRed.
  }
  split; tea; constructor; intros.
  - eapply redwfSubstTerm.
    1: now eapply validTm.
    now eapply validRed.
  - eapply transEqTerm. 2: eapply transEqTerm.
    + now eapply validTmEq.
    + now eapply validTmExt.
    + eapply LRTmEqSym. eapply LRTmEqRedConv.
      1: eapply LRTyEqSym; now eapply validTyExt.
      now eapply validTmEq.
      Unshelve. all: tea.
Qed.
   
End Reduction.
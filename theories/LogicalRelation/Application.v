
From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst Notations Context NormalForms Weakening GenericTyping LogicalRelation DeclarativeInstance.
From LogRel.LogicalRelation Require Import Induction Irrelevance Escape Reflexivity Weakening Neutral Transitivity Reduction NormalRed.

Set Universe Polymorphism.

Ltac fold_subst_term := fold subst_term in *.

Smpl Add fold_subst_term : refold.

Section Application.
Context `{GenericTypingProperties}.

Set Printing Primitive Projection Parameters.

Section AppTerm.
  Context {Γ t u nF F G l l' l''}
    (hΠ : [Γ ||-Π<l> tProd nF F G])
    {RF : [Γ ||-<l'> F]}
    (Rt : [Γ ||-<l> t : tProd nF F G | LRPi' (normRedΠ0 hΠ)])
    (Ru : [Γ ||-<l'> u : F | RF])
    (RGu : [Γ ||-<l''> G[u..]]).

  Lemma app_id : [Γ ||-<l''> tApp (PiRedTm.nf Rt) u : G[u..] | RGu].
  Proof.
    assert (wfΓ := wfc_wft (escape RF)).
    replace (PiRedTm.nf _) with (PiRedTm.nf Rt)⟨@wk_id Γ⟩ by now bsimpl.
    irrelevance0.  2: eapply (PiRedTm.app Rt).
    cbn; now bsimpl.
    Unshelve. 1: eassumption.
    cbn; irrelevance0; tea; now bsimpl.
  Qed.

  Lemma appTerm0 :
      [Γ ||-<l''> tApp t u : G[u..] | RGu]
      × [Γ ||-<l''> tApp t u ≅ tApp (PiRedTm.nf Rt) u : G[u..] | RGu].
  Proof.
    eapply redwfSubstTerm.
    1: unshelve eapply app_id; tea.
    escape.
    eapply redtmwf_app.
    1: apply Rt.
    easy.
  Qed.

End AppTerm.

Lemma appTerm {Γ t u nF F G l}
  (RΠ : [Γ ||-<l> tProd nF F G])
  {RF : [Γ ||-<l> F]}
  (Rt : [Γ ||-<l> t : tProd nF F G | RΠ])
  (Ru : [Γ ||-<l> u : F | RF])
  (RGu : [Γ ||-<l> G[u..]]) : 
  [Γ ||-<l> tApp t u : G[u..]| RGu].
Proof.  
  unshelve eapply appTerm0.
  7:irrelevance.
  3: exact (invLRΠ RΠ).
  all: eassumption.
Qed.


Lemma appcongTerm {Γ t t' u u' nF F G l l'}
  (RΠ : [Γ ||-<l> tProd nF F G]) 
  {RF : [Γ ||-<l'> F]}
  (Rtt' : [Γ ||-<l> t ≅ t' : tProd nF F G | RΠ])
  (Ru : [Γ ||-<l'> u : F | RF])
  (Ru' : [Γ ||-<l'> u' : F | RF])
  (Ruu' : [Γ ||-<l'> u ≅ u' : F | RF ])
  (RGu : [Γ ||-<l'> G[u..]])
   :
    [Γ ||-<l'> tApp t u ≅ tApp t' u' : G[u..] | RGu].
Proof.
  set (hΠ := invLRΠ RΠ); pose (RΠ' := LRPi' (normRedΠ0 hΠ)).
  assert [Γ ||-<l> t ≅ t' : tProd nF F G | RΠ'] as [Rt Rt' ? eqApp] by irrelevance.
  set (h := invLRΠ _) in hΠ.
  epose proof (e := redtywf_whnf (PiRedTyPack.red h) whnf_tProd); 
  symmetry in e; injection e; clear e; 
  destruct h as [??????? domRed codRed codExt] ; clear RΠ Rtt'; 
  intros; cbn in *; subst. 
  assert (wfΓ : [|-Γ]) by gen_typing.
  assert [Γ ||-<l> u' : F⟨@wk_id Γ⟩ | domRed _ (@wk_id Γ) wfΓ] by irrelevance.
  assert [Γ ||-<l> u : F⟨@wk_id Γ⟩ | domRed _ (@wk_id Γ) wfΓ] by irrelevance.
  assert (RGu' : [Γ ||-<l> G[u'..]]).
  1:{
    replace G[u'..] with G[u' .: @wk_id Γ >> tRel] by now bsimpl.
    now eapply (codRed _ u' (@wk_id Γ)).
  }
  assert (RGuu' : [Γ ||-<l>  G [u'..] ≅ G[u..]  | RGu']).
  1:{
    replace G[u..] with G[u .: @wk_id Γ >> tRel] by now bsimpl.
    irrelevance0.
    2: unshelve eapply codExt.
    6: eapply LRTmEqSym; irrelevance.
    2-4: tea.
    now bsimpl.
  }
  eapply transEqTerm; eapply transEqTerm.
  - eapply (snd (appTerm0 hΠ Rt Ru RGu)).
  - unshelve epose  proof (eqApp _ u (@wk_id Γ) wfΓ _).  1: irrelevance. 
    replace (PiRedTm.nf Rt) with (PiRedTm.nf Rt)⟨@wk_id Γ⟩ by now bsimpl.
    irrelevance.
  - unshelve epose proof (PiRedTm.eq Rt' (a:= u) (b:=u') (@wk_id Γ) wfΓ _ _ _).
    all: irrelevance.
  - replace (_)⟨_⟩ with (PiRedTm.nf Rt') by now bsimpl.
    eapply LRTmEqRedConv; tea.
    eapply LRTmEqSym.
    eapply (snd (appTerm0 hΠ Rt' Ru' RGu')).
Qed.

End Application.



(** * LogRel.LogicalRelation.Induction: good induction principles for the logical relation. *)
From LogRel.AutoSubst Require Import core unscoped Ast Extra.
From LogRel Require Import Utils BasicAst Notations Context NormalForms Weakening UntypedReduction
GenericTyping LogicalRelation.

Set Universe Polymorphism.

(** As Coq is not currently able to define induction principles for nested inductive types
as our LR, we need to prove them by hand. We use this occasion to write down principles which
do not directly correspond to what LR would give us. More precisely, our induction principles:
- handle the two levels uniformly, rather than having to do two separate
  proofs, one at level zero and one at level one;
- apply directly to an inhabitant of the bundled logical relation, rather than the raw LR;
- give a more streamlined minor premise to prove for the case of Π type reducibility,
  which hides the separation needed in LR between the reducibility data and its adequacy
  (ie the two ΠA and ΠAad arguments to constructor LRPi).
Also, and crucially, all induction principles are universe-polymorphic, so that their usage
does not create global constraints on universes. *)

Section Inductions.
  Context `{ta : tag}
    `{!WfContext ta} `{!WfType ta} `{!Typing ta}
    `{!ConvType ta} `{!ConvTerm ta} `{!ConvNeuConv ta}
    `{!RedType ta} `{!TypeNf ta} `{!TypeNe ta} `{!RedTerm ta} `{!TermNf ta} `{!TermNe ta}.

(** ** Embedding *)

(** Reducibility at a lower level implies reducibility at a higher level, and their decoding are the
same. Both need to be proven simultaneously, because of contravariance in the product case. *)

  Fixpoint LR_embedding@{i j k l} {l l'} (l_ : l << l')
    {Γ A rEq rTe rTeEq} (lr : LogRel@{i j k l} l Γ A rEq rTe rTeEq) {struct lr} : (LogRel@{i j k l} l' Γ A rEq rTe rTeEq) :=
    let embedΠad {Γ A} {ΠA : [Γ ||-Πd A]} (ΠAad : PiRedTyAdequate _ ΠA) :=
        {|
          PiRedTy.domAd :=
            fun (Δ : context) (ρ : Δ ≤ _) (h : [  |- Δ]) => LR_embedding l_ (ΠAad.(PiRedTy.domAd) ρ h) ;
          PiRedTy.codAd :=
            fun (Δ : context) (a : term) (ρ : Δ ≤ _) (h : [  |- Δ])
              (ha : [PiRedTy.domRed ΠA ρ h | Δ ||- a : _]) =>
            LR_embedding l_ (ΠAad.(PiRedTy.codAd) ρ h ha)
        |}
    in
    match lr with
    | LRU _ H =>
        match
          (match l_ with Oi => fun H' => elim H'.(URedTy.lt) end H)
        with end
    | LRne _ neA => LRne _ neA
    | LRPi _ ΠA ΠAad => LRPi _ ΠA (embedΠad ΠAad)
    | LRNat _ NA => LRNat _ NA
    end.

  (** A basic induction principle, that handles only the first point in the list above *)

  Notation PiHyp P Γ ΠA HAad G :=
    ((forall {Δ} (ρ : Δ ≤ Γ) (h : [ |- Δ]),
        P (HAad.(PiRedTy.domAd) ρ h)) ->
      (forall {Δ a} (ρ : Δ ≤ Γ) (h : [ |- Δ ]) 
        (ha : [ ΠA.(PiRedTy.domRed) ρ h | Δ ||- a : ΠA.(PiRedTy.dom)⟨ρ⟩ ]),
        P (HAad.(PiRedTy.codAd) ρ h ha)) -> G).

  Theorem LR_rect@{i j k o}
    (l : TypeLevel)
    (rec : forall l', l' << l -> RedRel@{i j})
    (P : forall {c t rEq rTe rTeEq},
      LR@{i j k} rec c t rEq rTe rTeEq  -> Type@{o}) :

    (forall (Γ : context) A (h : [Γ ||-U<l> A]),
      P (LRU rec h)) ->

    (forall (Γ : context) (A : term) (neA : [Γ ||-ne A]),
      P (LRne rec neA)) -> 

    (forall (Γ : context) (A : term) (ΠA : PiRedTy@{j} Γ A) (HAad : PiRedTyAdequate (LR rec) ΠA),
      PiHyp P Γ ΠA HAad (P (LRPi rec ΠA HAad))) ->

    (forall Γ A (NA : [Γ ||-Nat A]), P (LRNat rec NA)) ->

    forall (Γ : context) (t : term) (rEq rTe : term -> Type@{j})
      (rTeEq  : term -> term -> Type@{j}) (lr : LR@{i j k} rec Γ t rEq rTe rTeEq),
      P lr.
  Proof.
    cbn.
    intros HU Hne HPi HNat.
    fix HRec 6.
    destruct lr.
    - eapply HU.
    - eapply Hne.
    - eapply HPi.
      all: intros ; eapply HRec.
    - eapply HNat.
  Defined.

  Definition LR_rec@{i j k} := LR_rect@{i j k Set}.
  
  Notation PiHypLogRel P Γ ΠA G :=
    ((forall {Δ} (ρ : Δ ≤ Γ) (h : [ |- Δ]), P (ΠA.(PiRedTyPack.domRed) ρ h).(LRAd.adequate)) ->
    (forall {Δ a} (ρ : Δ ≤ Γ) (h : [ |- Δ ]) 
      (ha : [ Δ ||-< _ > a : ΠA.(PiRedTyPack.dom)⟨ρ⟩ |  ΠA.(PiRedTyPack.domRed) ρ h ]),
      P (ΠA.(PiRedTyPack.codRed) ρ h ha).(LRAd.adequate)) -> G).


  (** Induction principle specialized to LogRel as the reducibility relation on lower levels *)
  Theorem LR_rect_LogRelRec@{i j k l o}
    (P : forall {l Γ t rEq rTe rTeEq},
    LogRel@{i j k l} l Γ t rEq rTe rTeEq -> Type@{o}) :

    (forall l (Γ : context) A (h : [Γ ||-U<l> A]),
      P (LRU (LogRelRec l) h)) ->

    (forall (l : TypeLevel) (Γ : context) (A : term) (neA : [Γ ||-ne A]),
      P (LRne (LogRelRec l) neA)) ->

    (forall (l : TypeLevel) (Γ : context) (A : term) (ΠA : PiRedTyPack@{i j k l} Γ A l),
      PiHypLogRel P Γ ΠA (P (LRPi' ΠA).(LRAd.adequate ))) ->
    
    (forall l Γ A (NA : [Γ ||-Nat A]), P (LRNat (LogRelRec l) NA)) ->

    forall (l : TypeLevel) (Γ : context) (t : term) (rEq rTe : term -> Type@{k})
      (rTeEq  : term -> term -> Type@{k}) (lr : LR@{j k l} (LogRelRec@{i j k} l) Γ t rEq rTe rTeEq),
      P lr.
  Proof.
    intros HU Hne HPi **; eapply LR_rect@{j k l o}.
    1,2,4: auto.
    - intros; eapply (HPi _ _ _ (PiRedTyPack.pack ΠA HAad)); eauto.
  Defined.


  Theorem LR_rect_TyUr@{i j k l o}
    (P : forall {l Γ A}, [LogRel@{i j k l} l | Γ ||- A] -> Type@{o}) :

    (forall l (Γ : context) A (h : [Γ ||-U<l> A]),
      P (LRU_ h)) ->

    (forall (l : TypeLevel) (Γ : context) (A : term) (neA : [Γ ||-ne A]),
      P (LRne_ l neA)) ->

    (forall (l : TypeLevel) (Γ : context) (A : term) (ΠA : PiRedTyPack@{i j k l} Γ A l),
      (forall {Δ} (ρ : Δ ≤ Γ) (h : [ |- Δ]), P (ΠA.(PiRedTyPack.domRed) ρ h)) ->
      (forall {Δ a} (ρ : Δ ≤ Γ) (h : [ |- Δ ]) 
       (ha : [ ΠA.(PiRedTyPack.domRed) ρ h | Δ ||- a : ΠA.(PiRedTyPack.dom)⟨ρ⟩ ]),
      P (ΠA.(PiRedTyPack.codRed) ρ h ha)) ->
    P (LRPi' ΠA)) ->

    (forall l Γ A (NA : [Γ ||-Nat A]), P (LRNat_ l NA)) ->

    forall (l : TypeLevel) (Γ : context) (A : term) (lr : [LogRel@{i j k l} l | Γ ||- A]),
      P lr.
  Proof.
    intros HU Hne HPi HNat l Γ A lr.
    apply (LR_rect_LogRelRec@{i j k l o} (fun l Γ A _ _ _ lr => P l Γ A (LRbuild lr))).
    1-4: auto.
  Defined.

  Notation PiHyp0 P Γ ΠA HAad G :=
    ((forall {Δ} (ρ : Δ ≤ Γ) (h : [ |- Δ]),
        P (HAad.(PiRedTy.domAd) ρ h)) ->
      (forall {Δ a} (ρ : Δ ≤ Γ) (h : [ |- Δ ]) 
        (ha : [ ΠA.(PiRedTy.domRed) ρ h | Δ ||- a : ΠA.(PiRedTy.dom)⟨ρ⟩ ]),
        P (HAad.(PiRedTy.codAd) ρ h ha)) -> G).


  (** Induction principle specialized at level 0 to minimize universe constraints. *)
  (* Useful anywhere ? *)
  Theorem LR_rect0@{i j k o}
    (P : forall {c t rEq rTe rTeEq},
      LogRel0@{i j k} c t rEq rTe rTeEq  -> Type@{o}) :

    (forall (Γ : context) (A : term) (neA : [Γ ||-ne A]),
      P (LRne rec0 neA)) -> 
    
    (forall (Γ : context) (A : term) (ΠA : PiRedTy@{j} Γ A) (HAad : PiRedTyAdequate LogRel0@{i j k} ΠA),
      PiHyp0 P Γ ΠA HAad (P (LRPi rec0 ΠA HAad))) ->

    (forall Γ A (NA : [Γ ||-Nat A]), P (LRNat rec0 NA)) ->

    forall (Γ : context) (t : term) (rEq rTe : term -> Type@{j})
      (rTeEq  : term -> term -> Type@{j}) (lr : LogRel0@{i j k} Γ t rEq rTe rTeEq),
      P lr.
  Proof.
    cbn.
    intros Hne HPi HNat.
    fix HRec 6.
    destruct lr.
    - destruct H as [? lt]; destruct (elim lt).
    - eapply Hne.
    - eapply HPi; intros ; eapply HRec.
    - eapply HNat.
  Defined.

End Inductions.

(** ** Inversion principles *)

Section Inversions.
  Context `{ta : tag}
    `{!WfContext ta} `{!WfType ta} `{!Typing ta}
    `{!ConvType ta} `{!ConvTerm ta} `{!ConvNeuConv ta}
    `{!RedType ta} `{!TypeNf ta} `{!TypeNe ta} `{!RedTerm ta} `{!TermNf ta} `{!TermNe ta} `{!RedTypeProperties}
    `{!TypeNeProperties}.

  Lemma invLR {Γ l A A'} (lr : [Γ ||-<l> A]) (r : [A ⇒* A']) (w : isType A') :
    match w return Type with
    | UnivType => [Γ ||-U<l> A]
    | ProdType => [Γ ||-Π<l> A]
    | NatType => [Γ ||-Nat A]
    | NeType _ => [Γ ||-ne A]
    end.
  Proof.
    revert A' r w.
    pattern l, Γ, A, lr ; eapply LR_rect_TyUr; clear l Γ A lr.
    - intros * h ? red whA.
      assert (A' = U) as ->.
      {
        eapply whred_det.
        1-3: gen_typing.
        eapply redty_red, h.
      }
      dependent inversion whA.
      1: assumption.
      exfalso.
      gen_typing.
    - intros * ? A' red whA.
      enough ({w' & whA = NeType w'}) as [? ->] by easy.
      destruct neA as [A'' redA neA''].
      apply ty_ne_whne in neA''.
      assert (A' = A'') as <-.
      + eapply whred_det.
        1-3: gen_typing.
        eapply redty_red, redA.
      + dependent inversion whA ; subst.
        1-3: inv_whne.
        now eexists.
    - intros ??? PiA _ _ A' red whA.
      enough (∑ na dom cod, A' = tProd na cod dom) as (?&?&?&->).
      + dependent inversion whA ; subst.
        2: exfalso ; gen_typing.
        assumption.
      + destruct PiA as [??? redA].
        do 3 eexists.
        eapply whred_det.
        1-3: gen_typing.
        eapply redty_red, redA.
    - intros ??? [redA] ???.
      enough (A' = tNat) as ->.
      + dependent inversion w. 
        1: now econstructor.
        inv_whne.
      + eapply whred_det; tea.
        all: gen_typing.
  Qed.

  Lemma invLRU {Γ l} : [Γ ||-<l> U] -> [Γ ||-U<l> U].
  Proof.
    intros.
    now unshelve eapply (invLR _ redIdAlg UnivType).
  Qed.

  Lemma invLRne {Γ l A} : whne A -> [Γ ||-<l> A] -> [Γ ||-ne A].
  Proof.
    intros.
    now unshelve eapply  (invLR _ redIdAlg (NeType _)).
  Qed.

  Lemma invLRΠ {Γ l na dom cod} : [Γ ||-<l> tProd na dom cod] -> [Γ ||-Π<l> tProd na dom cod].
  Proof.
    intros.
    now unshelve eapply  (invLR _ redIdAlg ProdType).
  Qed.

  (* invLRNat is useless *)

End Inversions.
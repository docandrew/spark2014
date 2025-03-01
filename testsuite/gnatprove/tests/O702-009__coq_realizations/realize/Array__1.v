(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require bool.Bool.
Require map.Map.

(* Why3 assumption *)
Definition unit := unit.

(* Why3 goal *)
Definition qtmark : Type.
exact unit.
Defined.

(* Why3 goal *)
Definition t : Type.
exact Z.
Defined.

(* Why3 goal *)
Definition le: t -> t -> Prop.
exact Z.le.
Defined.

(* Why3 goal *)
Definition lt: t -> t -> Prop.
exact Z.lt.
Defined.

(* Why3 goal *)
Definition gt: t -> t -> Prop.
exact Z.gt.
Defined.

(* Why3 goal *)
Definition add: t -> t -> t.
intros x y; exact (x + y)%Z.
Defined.

(* Why3 goal *)
Definition sub: t -> t -> t.
intros x y; exact (x - y)%Z.
Defined.

(* Why3 goal *)
Definition one: t.
exact (1)%Z.
Defined.

(* Why3 goal *)
Definition component_type : Type.
exact Z.
Defined.

(* Why3 assumption *)
Definition map := (map.Map.map t component_type).

(* Why3 assumption *)
Inductive map__ref :=
  | mk_map__ref : (map.Map.map t component_type) -> map__ref.
Axiom map__ref_WhyType : WhyType map__ref.
Existing Instance map__ref_WhyType.

(* Why3 assumption *)
Definition map__content (v:map__ref): (map.Map.map t component_type) :=
  match v with
  | (mk_map__ref x) => x
  end.

Fixpoint array_eq (a : map.Map.map t component_type)
  (af : t) (b : map.Map.map t component_type) (bf : t) (h : nat) : bool :=
  match h with
  | O => Z.eqb (a af) (b bf)
  | S (n) => andb (Z.eqb (a af) (b bf)) (array_eq a (af + 1)%Z b (bf + 1)%Z n)
  end.

Lemma array_eq_def:
forall (a:(map.Map.map t component_type)),
 forall (af:t),
  forall (b:(map.Map.map t component_type)),
   forall (bf:t),
    forall (h:nat),
      array_eq a af b bf h = true <->
      (forall (i:t),
        (af <= i <= af + Z.of_nat h)%Z ->
            a i = b ((bf - af) + i))%Z.
intros a af b bf h.
generalize af bf; clear af bf.
induction h; intros af bf; split.
 - simpl; intro Heq; apply Z.eqb_eq in Heq.
   intros i [Hil Hir].
   rewrite <- Zplus_0_r_reverse in Hir.
   apply (Z.le_antisymm _ _ Hir) in Hil.
   rewrite Hil.
   rewrite Heq.
   rewrite Z.sub_simpl_r.
   auto.
 - simpl; intro Helmt.
   rewrite (Helmt af) by omega.
   rewrite Z.sub_simpl_r.
   apply Z.eqb_eq; auto.
 - unfold array_eq; fold array_eq; unfold andb.
   destruct (Z.eqb (a af) (b bf)) eqn:Heq;
   [apply Z.eqb_eq in Heq|intro Hwrong; contradict Hwrong; auto].
   intros Helmt i [Hil Hir].
   rewrite <- Nat.add_1_r in Hir.
   rewrite Nat2Z.inj_add in Hir; simpl in Hir.
   rewrite <- (Zminus_plus_simpl_r bf af 1%Z).
   destruct (Z_le_lt_eq_dec _ _ Hil) as [Haf | Haf].
   * apply IHh; try omega; auto.
   * rewrite <- Haf.
     rewrite Zminus_plus_simpl_r.
     rewrite Z.sub_simpl_r; auto.
 - unfold array_eq; fold array_eq; unfold andb.
   intro Helmt.
   rewrite (Helmt af) by omega.
   rewrite Z.sub_simpl_r.
   rewrite Z.eqb_refl.
   apply IHh.
   intros i [Hil Hir].
   rewrite Zminus_plus_simpl_r.
   apply Helmt.
   rewrite <- Nat.add_1_r.
   rewrite Nat2Z.inj_add; simpl.
   split; omega.
Qed.

(* Why3 goal *)
Definition bool_eq: (map.Map.map t component_type) -> t -> t ->
  (map.Map.map t component_type) -> t -> t -> bool.
intros a af al b bf bl.
destruct (Z_gt_le_dec af al) as [Ha|Ha].
exact (Zlt_bool bl bf).
destruct (Z_eq_dec (al - af)%Z (bl - bf)%Z) as [He|He]; [|exact false].
exact (array_eq a af b bf (Z.to_nat (al - af)%Z)).
Defined.

(* Why3 goal *)
Lemma T__ada_array___equal_def :
forall (a:(map.Map.map t component_type)),
 forall (af:t),
  forall (al:t),
   forall (b:(map.Map.map t component_type)),
    forall (bf:t),
     forall (bl:t),
      (((((le af al) /\ ((add (sub al af) one) = (add (sub bl bf) one)))
         \/ ((~ (le af al)) /\ (gt bf bl)))
        /\ forall (i:t),
            ((le af i) /\ (le i al)) ->
            ((a i) = (b (add (sub bf af) i)))) ->
       ((bool_eq a af al b bf bl) = true))
      /\ (((bool_eq a af al b bf bl) = true) ->
          ((((le af al) -> ((add (sub al af) one) = (add (sub bl bf) one)))
            /\ ((~ (le af al)) -> (gt bf bl)))
           /\ forall (i:t),
               ((le af i) /\ (le i al)) ->
               ((a i) = (b (add (sub bf af) i))))).
intros a af al b bf bl.
unfold le; unfold gt; unfold add; unfold one; unfold sub; unfold bool_eq.
split.
 - intros [[[Ha Heq_lgth1] | [Ha_emp Hb_emp]] Helmt].
   * case (Z_gt_le_dec af al) as [Hwrong | _]; [contradiction |].
     case (Z.eq_dec (al - af) (bl - bf)) as [Heq_lgth | Hwrong].
     + clear Heq_lgth1.
       apply array_eq_def.
       apply Zle_minus_le_0 in Ha.
       apply Z2Nat.id in Ha.
       rewrite Ha.
       intros i [Hil Hir].
       apply Helmt; split; omega.
     + contradict Hwrong.
       apply Zeq_plus_swap in Heq_lgth1.
       rewrite Heq_lgth1; ring.
   * case (Z_gt_le_dec af al) as [_ | Hwrong]; [| contradiction].
     apply Zlt_is_lt_bool; omega.
 - case (Z_gt_le_dec af al) as [Ha | Ha].
   * intro Hb; split; [split | ].
     + intro Hwrong; contradict Hwrong; omega.
     + intros _; apply Zlt_is_lt_bool in Hb; omega.
     + intros i Hwrong; contradict Hwrong; omega.
   * case (Z.eq_dec (al - af) (bl - bf)) as [Heq_lgth | _];
     [|intro Hwrong; contradict Hwrong; auto].
     split; [split | ].
     + intros _; rewrite Heq_lgth; auto.
     + intro Hwrong; contradiction.
     + apply Zle_minus_le_0 in Ha.
       apply Z2Nat.id in Ha.
       rewrite <- (Zplus_minus af al).
       rewrite <- Ha.
       apply array_eq_def; auto.
Qed.

(* Why3 goal *)
Definition slide: (map.Map.map t component_type) -> t -> t ->
  (map.Map.map t component_type).
intros a of nf.
destruct (Z.eq_dec of nf) as [_ | _].
exact a.
exact (fun x => a (x - nf + of)%Z).
Defined.

(* Why3 goal *)
Lemma slide_eq :
forall (a:(map.Map.map t component_type)),
 forall (first:t), ((slide a first first) = a).
intros a first.
unfold slide; simpl.
destruct (Z.eq_dec first first) as [_ | Hwrong];
[| contradict Hwrong]; auto.
Qed.

(* Why3 goal *)
Lemma slide_def :
forall (a:(map.Map.map t component_type)),
 forall (old_first:t),
  forall (new_first:t),
   forall (i:t),
    (((slide a old_first new_first) i) = (a
                                           (sub i
                                             (sub new_first
                                               old_first)))).
intros a old_first new_first i.
unfold slide; unfold sub; simpl.
destruct (Z.eq_dec old_first new_first) as [Ha | _].
 - rewrite Ha.
   rewrite Zminus_diag.
   rewrite <- Zminus_0_l_reverse.
   auto.
 - rewrite Z.sub_sub_distr.
   auto.
Qed.

Require map.Const.

(* Why3 goal *)
Definition const : component_type -> map.Map.map.
Proof.
intros e.
exact (map.Const.const e).
Defined.

(* Why3 goal *)
Lemma const_def :
  forall (v:component_type), forall (i:t), ((get (const v) i) = v).
Proof.
intros v i.
reflexivity.
Qed.

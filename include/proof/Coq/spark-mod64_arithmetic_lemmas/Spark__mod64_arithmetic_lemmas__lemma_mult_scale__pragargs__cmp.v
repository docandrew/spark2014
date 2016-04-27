(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require bool.Bool.
Require int.Int.
Require int.Abs.
Require int.MinMax.
Require int.EuclideanDivision.
Require bv.Pow2int.
Require bv.BV_Gen.

(* Why3 assumption *)
Definition unit := unit.

Axiom us_private : Type.
Parameter us_private_WhyType : WhyType us_private.
Existing Instance us_private_WhyType.

Parameter us_null_ext__: us_private.

(* Why3 assumption *)
Definition us_fixed := Z.

Axiom us_type_of_heap : Type.
Parameter us_type_of_heap_WhyType : WhyType us_type_of_heap.
Existing Instance us_type_of_heap_WhyType.

(* Why3 assumption *)
Inductive us_type_of_heap__ref :=
  | mk___type_of_heap__ref : us_type_of_heap -> us_type_of_heap__ref.
Axiom us_type_of_heap__ref_WhyType : WhyType us_type_of_heap__ref.
Existing Instance us_type_of_heap__ref_WhyType.

(* Why3 assumption *)
Definition us_type_of_heap__content
  (v:us_type_of_heap__ref): us_type_of_heap :=
  match v with
  | (mk___type_of_heap__ref x) => x
  end.

Axiom us_image : Type.
Parameter us_image_WhyType : WhyType us_image.
Existing Instance us_image_WhyType.

(* Why3 assumption *)
Inductive int__ref :=
  | mk_int__ref : Z -> int__ref.
Axiom int__ref_WhyType : WhyType int__ref.
Existing Instance int__ref_WhyType.

(* Why3 assumption *)
Definition int__content (v:int__ref): Z :=
  match v with
  | (mk_int__ref x) => x
  end.

(* Why3 assumption *)
Inductive bool__ref :=
  | mk_bool__ref : bool -> bool__ref.
Axiom bool__ref_WhyType : WhyType bool__ref.
Existing Instance bool__ref_WhyType.

(* Why3 assumption *)
Definition bool__content (v:bool__ref): bool :=
  match v with
  | (mk_bool__ref x) => x
  end.

(* Why3 assumption *)
Inductive real__ref :=
  | mk_real__ref : R -> real__ref.
Axiom real__ref_WhyType : WhyType real__ref.
Existing Instance real__ref_WhyType.

(* Why3 assumption *)
Definition real__content (v:real__ref): R :=
  match v with
  | (mk_real__ref x) => x
  end.

(* Why3 assumption *)
Inductive us_private__ref :=
  | mk___private__ref : us_private -> us_private__ref.
Axiom us_private__ref_WhyType : WhyType us_private__ref.
Existing Instance us_private__ref_WhyType.

(* Why3 assumption *)
Definition us_private__content (v:us_private__ref): us_private :=
  match v with
  | (mk___private__ref x) => x
  end.

(* Why3 assumption *)
Definition int__ref___projection (a:int__ref): Z := (int__content a).

(* Why3 assumption *)
Definition bool__ref___projection (a:bool__ref): bool := (bool__content a).

(* Why3 assumption *)
Definition real__ref___projection (a:real__ref): R := (real__content a).

(* Why3 assumption *)
Definition us_private__ref___projection (a:us_private__ref): us_private :=
  (us_private__content a).

Parameter us_compatible_tags: Z -> Z -> Prop.

Axiom us_compatible_tags_refl : forall (tag:Z), (us_compatible_tags tag tag).

Axiom t : Type.
Parameter t_WhyType : WhyType t.
Existing Instance t_WhyType.

Parameter nth: t -> Z -> bool.

Axiom nth_out_of_bound : forall (x:t) (n:Z),
                          ((n < 0%Z)%Z \/ (64%Z <= n)%Z) ->
                          ((nth x n) = false).

Parameter zeros: t.

Axiom Nth_zeros : forall (n:Z), ((nth zeros n) = false).

Parameter ones: t.

Axiom Nth_ones : forall (n:Z),
                  ((0%Z <= n)%Z /\ (n < 64%Z)%Z) -> ((nth ones n) = true).

Parameter bw_and: t -> t -> t.

Axiom Nth_bw_and : forall (v1:t) (v2:t) (n:Z),
                    ((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                    ((nth (bw_and v1 v2) n) = (Init.Datatypes.andb (nth v1 n) 
                    (nth v2 n))).

Parameter bw_or: t -> t -> t.

Axiom Nth_bw_or : forall (v1:t) (v2:t) (n:Z),
                   ((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                   ((nth (bw_or v1 v2) n) = (Init.Datatypes.orb (nth v1 n) 
                   (nth v2 n))).

Parameter bw_xor: t -> t -> t.

Axiom Nth_bw_xor : forall (v1:t) (v2:t) (n:Z),
                    ((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                    ((nth (bw_xor v1 v2) n) = (Init.Datatypes.xorb (nth v1 n) 
                    (nth v2 n))).

Parameter bw_not: t -> t.

Axiom Nth_bw_not : forall (v:t) (n:Z),
                    ((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                    ((nth (bw_not v) n) = (Init.Datatypes.negb (nth v n))).

Parameter lsr: t -> Z -> t.

Axiom Lsr_nth_low : forall (b:t) (n:Z) (s:Z),
                     (0%Z <= s)%Z ->
                     ((0%Z <= n)%Z ->
                      (((n + s)%Z < 64%Z)%Z ->
                       ((nth (lsr b s) n) = (nth b (n + s)%Z)))).

Axiom Lsr_nth_high : forall (b:t) (n:Z) (s:Z),
                      (0%Z <= s)%Z ->
                      ((0%Z <= n)%Z ->
                       ((64%Z <= (n + s)%Z)%Z -> ((nth (lsr b s) n) = false))).

Axiom lsr_zeros : forall (x:t), ((lsr x 0%Z) = x).

Parameter asr: t -> Z -> t.

Axiom Asr_nth_low : forall (b:t) (n:Z) (s:Z),
                     (0%Z <= s)%Z ->
                     (((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                      (((n + s)%Z < 64%Z)%Z ->
                       ((nth (asr b s) n) = (nth b (n + s)%Z)))).

Axiom Asr_nth_high : forall (b:t) (n:Z) (s:Z),
                      (0%Z <= s)%Z ->
                      (((0%Z <= n)%Z /\ (n < 64%Z)%Z) ->
                       ((64%Z <= (n + s)%Z)%Z ->
                        ((nth (asr b s) n) = (nth b (64%Z - 1%Z)%Z)))).

Axiom asr_zeros : forall (x:t), ((asr x 0%Z) = x).

Parameter lsl: t -> Z -> t.

Axiom Lsl_nth_high : forall (b:t) (n:Z) (s:Z),
                      ((0%Z <= s)%Z /\ ((s <= n)%Z /\ (n < 64%Z)%Z)) ->
                      ((nth (lsl b s) n) = (nth b (n - s)%Z)).

Axiom Lsl_nth_low : forall (b:t) (n:Z) (s:Z),
                     ((0%Z <= n)%Z /\ (n < s)%Z) ->
                     ((nth (lsl b s) n) = false).

Axiom lsl_zeros : forall (x:t), ((lsl x 0%Z) = x).

Parameter rotate_right: t -> Z -> t.

Axiom Nth_rotate_right : forall (v:t) (n:Z) (i:Z),
                          ((0%Z <= i)%Z /\ (i < 64%Z)%Z) ->
                          ((0%Z <= n)%Z ->
                           ((nth (rotate_right v n) i) = (nth v
                                                           (int.EuclideanDivision.mod1 (i + n)%Z
                                                             64%Z)))).

Parameter rotate_left: t -> Z -> t.

Axiom Nth_rotate_left : forall (v:t) (n:Z) (i:Z),
                         ((0%Z <= i)%Z /\ (i < 64%Z)%Z) ->
                         ((0%Z <= n)%Z ->
                          ((nth (rotate_left v n) i) = (nth v
                                                         (int.EuclideanDivision.mod1 (i - n)%Z
                                                           64%Z)))).

Parameter to_int: t -> Z.

Parameter to_uint: t -> Z.

Parameter of_int: Z -> t.

Axiom to_uint_extensionality : forall (v:t) (v':t),
                                ((to_uint v) = (to_uint v')) -> (v = v').

Axiom to_int_extensionality : forall (v:t) (v':t),
                               ((to_int v) = (to_int v')) -> (v = v').

(* Why3 assumption *)
Definition uint_in_range (i:Z): Prop :=
  (0%Z <= i)%Z /\ (i <= 18446744073709551615%Z)%Z.

Axiom to_uint_bounds : forall (v:t),
                        (0%Z <= (to_uint v))%Z
                        /\ ((to_uint v) < 18446744073709551616%Z)%Z.

Axiom to_uint_of_int : forall (i:Z),
                        ((0%Z <= i)%Z /\ (i < 18446744073709551616%Z)%Z) ->
                        ((to_uint (of_int i)) = i).

Axiom Of_int_zeros : (zeros = (of_int 0%Z)).

Axiom Of_int_ones : (ones = (of_int 18446744073709551615%Z)).

(* Why3 assumption *)
Definition ult (x:t) (y:t): Prop := ((to_uint x) < (to_uint y))%Z.

(* Why3 assumption *)
Definition ule (x:t) (y:t): Prop := ((to_uint x) <= (to_uint y))%Z.

(* Why3 assumption *)
Definition ugt (x:t) (y:t): Prop := ((to_uint y) < (to_uint x))%Z.

(* Why3 assumption *)
Definition uge (x:t) (y:t): Prop := ((to_uint y) <= (to_uint x))%Z.

(* Why3 assumption *)
Definition slt (v1:t) (v2:t): Prop := ((to_int v1) < (to_int v2))%Z.

(* Why3 assumption *)
Definition sle (v1:t) (v2:t): Prop := ((to_int v1) <= (to_int v2))%Z.

(* Why3 assumption *)
Definition sgt (v1:t) (v2:t): Prop := ((to_int v2) < (to_int v1))%Z.

(* Why3 assumption *)
Definition sge (v1:t) (v2:t): Prop := ((to_int v2) <= (to_int v1))%Z.

Parameter add: t -> t -> t.

Axiom to_uint_add : forall (v1:t) (v2:t),
                     ((to_uint (add v1 v2)) = (int.EuclideanDivision.mod1 (
                                                (to_uint v1) + (to_uint v2))%Z
                                                18446744073709551616%Z)).

Axiom to_uint_add_bounded : forall (v1:t) (v2:t),
                             (((to_uint v1) + (to_uint v2))%Z < 18446744073709551616%Z)%Z ->
                             ((to_uint (add v1 v2)) = ((to_uint v1) + 
                             (to_uint v2))%Z).

Parameter sub: t -> t -> t.

Axiom to_uint_sub : forall (v1:t) (v2:t),
                     ((to_uint (sub v1 v2)) = (int.EuclideanDivision.mod1 (
                                                (to_uint v1) - (to_uint v2))%Z
                                                18446744073709551616%Z)).

Axiom to_uint_sub_bounded : forall (v1:t) (v2:t),
                             ((0%Z <= ((to_uint v1) - (to_uint v2))%Z)%Z
                              /\ (((to_uint v1) - (to_uint v2))%Z < 18446744073709551616%Z)%Z) ->
                             ((to_uint (sub v1 v2)) = ((to_uint v1) - 
                             (to_uint v2))%Z).

Parameter neg: t -> t.

Axiom to_uint_neg : forall (v:t),
                     ((to_uint (neg v)) = (int.EuclideanDivision.mod1 (-
                                            (to_uint v))%Z
                                            18446744073709551616%Z)).

Parameter mul: t -> t -> t.

Axiom to_uint_mul : forall (v1:t) (v2:t),
                     ((to_uint (mul v1 v2)) = (int.EuclideanDivision.mod1 (
                                                (to_uint v1) * (to_uint v2))%Z
                                                18446744073709551616%Z)).

Axiom to_uint_mul_bounded : forall (v1:t) (v2:t),
                             (((to_uint v1) * (to_uint v2))%Z < 18446744073709551616%Z)%Z ->
                             ((to_uint (mul v1 v2)) = ((to_uint v1) * 
                             (to_uint v2))%Z).

Parameter udiv: t -> t -> t.

Axiom to_uint_udiv : forall (v1:t) (v2:t),
                      ((to_uint (udiv v1 v2)) = (int.EuclideanDivision.div 
                                                  (to_uint v1) (to_uint v2))).

Parameter urem: t -> t -> t.

Axiom to_uint_urem : forall (v1:t) (v2:t),
                      ((to_uint (urem v1 v2)) = (int.EuclideanDivision.mod1 
                                                  (to_uint v1) (to_uint v2))).

Parameter lsr_bv: t -> t -> t.

Axiom lsr_bv_is_lsr : forall (x:t) (n:t),
                       ((lsr_bv x n) = (lsr x (to_uint n))).

Axiom to_uint_lsr : forall (v:t) (n:t),
                     ((to_uint (lsr_bv v n)) = (int.EuclideanDivision.div 
                                                 (to_uint v)
                                                 (bv.Pow2int.pow2 (to_uint n)))).

Parameter asr_bv: t -> t -> t.

Axiom asr_bv_is_asr : forall (x:t) (n:t),
                       ((asr_bv x n) = (asr x (to_uint n))).

Parameter lsl_bv: t -> t -> t.

Axiom lsl_bv_is_lsl : forall (x:t) (n:t),
                       ((lsl_bv x n) = (lsl x (to_uint n))).

Axiom to_uint_lsl : forall (v:t) (n:t),
                     ((to_uint (lsl_bv v n)) = (int.EuclideanDivision.mod1 (
                                                 (to_uint v) * (bv.Pow2int.pow2 
                                                                 (to_uint n)))%Z
                                                 18446744073709551616%Z)).

Parameter rotate_right_bv: t -> t -> t.

Parameter rotate_left_bv: t -> t -> t.

Axiom rotate_left_bv_is_rotate_left : forall (v:t) (n:t),
                                       ((rotate_left_bv v n) = (rotate_left v
                                                                 (to_uint n))).

Axiom rotate_right_bv_is_rotate_right : forall (v:t) (n:t),
                                         ((rotate_right_bv v n) = (rotate_right v
                                                                    (
                                                                    to_uint n))).

Parameter nth_bv: t -> t -> bool.

Axiom nth_bv_def : forall (x:t) (i:t),
                    ((nth_bv x i) = true) <->
                    ~ ((bw_and (lsr_bv x i) (of_int 1%Z)) = zeros).

Axiom Nth_bv_is_nth : forall (x:t) (i:t),
                       ((nth x (to_uint i)) = (nth_bv x i)).

Axiom Nth_bv_is_nth2 : forall (x:t) (i:Z),
                        ((0%Z <= i)%Z /\ (i < 18446744073709551616%Z)%Z) ->
                        ((nth_bv x (of_int i)) = (nth x i)).

Parameter eq_sub_bv: t -> t -> t -> t -> Prop.

Axiom eq_sub_bv_def : forall (a:t) (b:t) (i:t) (n:t),
                       let mask :=
                                   (lsl_bv (sub (lsl_bv (of_int 1%Z) n)
                                             (of_int 1%Z)) i) in
                       ((eq_sub_bv a b i n) <->
                        ((bw_and b mask) = (bw_and a mask))).

(* Why3 assumption *)
Definition eq_sub (a:t) (b:t) (i:Z) (n:Z): Prop :=
  forall (j:Z), ((i <= j)%Z /\ (j < (i + n)%Z)%Z) -> ((nth a j) = (nth b j)).

Axiom eq_sub_equiv : forall (a:t) (b:t) (i:t) (n:t),
                      (eq_sub a b (to_uint i) (to_uint n)) <-> (eq_sub_bv a b
                      i n).

Axiom Extensionality : forall (x:t) (y:t), (eq_sub x y 0%Z 64%Z) -> (x = y).

(* Why3 assumption *)
Inductive t__ref :=
  | mk_t__ref : t -> t__ref.
Axiom t__ref_WhyType : WhyType t__ref.
Existing Instance t__ref_WhyType.

(* Why3 assumption *)
Definition t__content (v:t__ref): t := match v with
                                       | (mk_t__ref x) => x
                                       end.

Parameter bool_eq: t -> t -> bool.

Axiom bool_eq_def : forall (x:t) (y:t),
                     ((x = y) -> ((bool_eq x y) = true))
                     /\ ((~ (x = y)) -> ((bool_eq x y) = false)).

Parameter bool_ne: t -> t -> bool.

Axiom bool_ne_def : forall (x:t) (y:t),
                     ((~ (x = y)) -> ((bool_ne x y) = true))
                     /\ ((x = y) -> ((bool_ne x y) = false)).

Parameter bool_lt: t -> t -> bool.

Axiom bool_lt_def : forall (x:t) (y:t),
                     ((ult x y) -> ((bool_lt x y) = true))
                     /\ ((~ (ult x y)) -> ((bool_lt x y) = false)).

Parameter bool_le: t -> t -> bool.

Axiom bool_le_def : forall (x:t) (y:t),
                     ((ule x y) -> ((bool_le x y) = true))
                     /\ ((~ (ule x y)) -> ((bool_le x y) = false)).

Parameter bool_gt: t -> t -> bool.

Axiom bool_gt_def : forall (x:t) (y:t),
                     ((ugt x y) -> ((bool_gt x y) = true))
                     /\ ((~ (ugt x y)) -> ((bool_gt x y) = false)).

Parameter bool_ge: t -> t -> bool.

Axiom bool_ge_def : forall (x:t) (y:t),
                     ((uge x y) -> ((bool_ge x y) = true))
                     /\ ((~ (uge x y)) -> ((bool_ge x y) = false)).

Parameter power: t -> Z -> t.

Axiom Power_0 : forall (x:t), ((power x 0%Z) = (of_int 1%Z)).

Axiom Power_1 : forall (x:t), ((power x 1%Z) = x).

Axiom Power_s : forall (x:t) (n:Z),
                 (0%Z <= n)%Z ->
                 ((power x (n + 1%Z)%Z) = (mul x (power x n))).

Axiom Power_s_alt : forall (x:t) (n:Z),
                     (0%Z < n)%Z ->
                     ((power x n) = (mul x (power x (n - 1%Z)%Z))).

Axiom Power_sum : forall (x:t) (n:Z) (m:Z),
                   (0%Z <= n)%Z ->
                   ((0%Z <= m)%Z ->
                    ((power x (n + m)%Z) = (mul (power x n) (power x m)))).

Axiom Power_mult : forall (x:t) (n:Z) (m:Z),
                    (0%Z <= n)%Z ->
                    ((0%Z <= m)%Z ->
                     ((power x (n * m)%Z) = (power (power x n) m))).

Axiom Power_mult2 : forall (x:t) (y:t) (n:Z),
                     (0%Z <= n)%Z ->
                     ((power (mul x y) n) = (mul (power x n) (power y n))).

Parameter bv_min: t -> t -> t.

Axiom bv_min_def : forall (x:t) (y:t),
                    ((ule x y) -> ((bv_min x y) = x))
                    /\ ((~ (ule x y)) -> ((bv_min x y) = y)).

Parameter bv_max: t -> t -> t.

Axiom bv_max_def : forall (x:t) (y:t),
                    ((ule x y) -> ((bv_max x y) = y))
                    /\ ((~ (ule x y)) -> ((bv_max x y) = x)).

Axiom bv_min_to_uint : forall (x:t) (y:t),
                        ((to_uint (bv_min x y)) = (ZArith.BinInt.Z.min 
                        (to_uint x) (to_uint y))).

Axiom bv_max_to_uint : forall (x:t) (y:t),
                        ((to_uint (bv_max x y)) = (ZArith.BinInt.Z.max 
                        (to_uint x) (to_uint y))).

Axiom uint : Type.
Parameter uint_WhyType : WhyType uint.
Existing Instance uint_WhyType.

Parameter attr__ATTRIBUTE_MODULUS: t.

(* Why3 assumption *)
Definition rep_type := t.

Parameter bool_eq1: Z -> Z -> bool.

Parameter bool_ne1: Z -> Z -> bool.

Parameter bool_lt1: Z -> Z -> bool.

Parameter bool_le1: Z -> Z -> bool.

Parameter bool_gt1: Z -> Z -> bool.

Parameter bool_ge1: Z -> Z -> bool.

Axiom bool_eq_axiom : forall (x:Z),
                       forall (y:Z), ((bool_eq1 x y) = true) <-> (x = y).

Axiom bool_ne_axiom : forall (x:Z),
                       forall (y:Z), ((bool_ne1 x y) = true) <-> ~ (x = y).

Axiom bool_lt_axiom : forall (x:Z),
                       forall (y:Z), ((bool_lt1 x y) = true) <-> (x < y)%Z.

Axiom bool_int__le_axiom : forall (x:Z),
                            forall (y:Z),
                             ((bool_le1 x y) = true) <-> (x <= y)%Z.

Axiom bool_gt_axiom : forall (x:Z),
                       forall (y:Z), ((bool_gt1 x y) = true) <-> (y < x)%Z.

Axiom bool_ge_axiom : forall (x:Z),
                       forall (y:Z), ((bool_ge1 x y) = true) <-> (y <= x)%Z.

Parameter bool_eq2: t -> t -> bool.

Axiom bool_eq_def1 : forall (x:t) (y:t),
                      ((x = y) -> ((bool_eq2 x y) = true))
                      /\ ((~ (x = y)) -> ((bool_eq2 x y) = false)).

Parameter attr__ATTRIBUTE_IMAGE: t -> us_image.

Parameter attr__ATTRIBUTE_VALUE__pre_check: us_image -> Prop.

Parameter attr__ATTRIBUTE_VALUE: us_image -> t.

Parameter to_rep: uint -> t.

Parameter of_rep: t -> uint.

Parameter user_eq: uint -> uint -> bool.

Parameter dummy: uint.

Axiom inversion_axiom : forall (x:uint), ((of_rep (to_rep x)) = x).

Axiom range_axiom : True.

(* Why3 assumption *)
Definition to_int1 (x:uint): Z := (to_uint (to_rep x)).

Axiom range_int_axiom : forall (x:uint), (uint_in_range (to_int1 x)).

Axiom coerce_axiom : forall (x:t), ((to_rep (of_rep x)) = x).

(* Why3 assumption *)
Inductive uint__ref :=
  | mk_uint__ref : uint -> uint__ref.
Axiom uint__ref_WhyType : WhyType uint__ref.
Existing Instance uint__ref_WhyType.

(* Why3 assumption *)
Definition uint__content (v:uint__ref): uint :=
  match v with
  | (mk_uint__ref x) => x
  end.

(* Why3 assumption *)
Definition uint__ref___projection (a:uint__ref): uint := (uint__content a).

(* Why3 assumption *)
Definition dynamic_invariant (temp___expr_216:t) (temp___is_init_213:bool)
  (temp___do_constant_214:bool) (temp___do_toplevel_215:bool): Prop := True.

Axiom pos : Type.
Parameter pos_WhyType : WhyType pos.
Existing Instance pos_WhyType.

Parameter attr__ATTRIBUTE_MODULUS1: t.

(* Why3 assumption *)
Definition in_range (x:t): Prop :=
  (ule (of_int 1%Z) x) /\ (ule x (of_int 18446744073709551615%Z)).

(* Why3 assumption *)
Definition in_range_int (x:Z): Prop :=
  (1%Z <= x)%Z /\ (x <= 18446744073709551615%Z)%Z.

(* Why3 assumption *)
Definition rep_type1 := t.

Parameter bool_eq3: t -> t -> bool.

Axiom bool_eq_def2 : forall (x:t) (y:t),
                      ((x = y) -> ((bool_eq3 x y) = true))
                      /\ ((~ (x = y)) -> ((bool_eq3 x y) = false)).

Parameter attr__ATTRIBUTE_IMAGE1: t -> us_image.

Parameter attr__ATTRIBUTE_VALUE__pre_check1: us_image -> Prop.

Parameter attr__ATTRIBUTE_VALUE1: us_image -> t.

Parameter to_rep1: pos -> t.

Parameter of_rep1: t -> pos.

Parameter user_eq1: pos -> pos -> bool.

Parameter dummy1: pos.

Axiom inversion_axiom1 : forall (x:pos), ((of_rep1 (to_rep1 x)) = x).

Axiom range_axiom1 : forall (x:pos), (in_range (to_rep1 x)).

(* Why3 assumption *)
Definition to_int2 (x:pos): Z := (to_uint (to_rep1 x)).

Axiom range_int_axiom1 : forall (x:pos), (in_range_int (to_int2 x)).

Axiom coerce_axiom1 : forall (x:t),
                       (in_range x) -> ((to_rep1 (of_rep1 x)) = x).

(* Why3 assumption *)
Inductive pos__ref :=
  | mk_pos__ref : pos -> pos__ref.
Axiom pos__ref_WhyType : WhyType pos__ref.
Existing Instance pos__ref_WhyType.

(* Why3 assumption *)
Definition pos__content (v:pos__ref): pos :=
  match v with
  | (mk_pos__ref x) => x
  end.

(* Why3 assumption *)
Definition pos__ref___projection (a:pos__ref): pos := (pos__content a).

(* Why3 assumption *)
Definition dynamic_invariant1 (temp___expr_222:t) (temp___is_init_219:bool)
  (temp___do_constant_220:bool) (temp___do_toplevel_221:bool): Prop :=
  ((temp___is_init_219 = true) \/ (ule (of_int 1%Z)
   (of_int 18446744073709551615%Z))) -> (in_range temp___expr_222).

Parameter val__: t.

Parameter attr__ATTRIBUTE_ADDRESS: Z.

Parameter scale_num: t.

Parameter attr__ATTRIBUTE_ADDRESS1: Z.

Parameter scale_denom: t.

Parameter attr__ATTRIBUTE_ADDRESS2: Z.

Parameter res: t.

Parameter attr__ATTRIBUTE_ADDRESS3: Z.

(* Why3 goal *)
Theorem WP_parameter_def : ((in_range scale_denom)
                            /\ ((ule scale_num scale_denom)
                                /\ (((scale_num = (of_int 0%Z)) \/ (ule val__
                                     (udiv (of_int 18446744073709551615%Z)
                                       scale_num)))
                                    /\ (res = (udiv (mul val__ scale_num)
                                                scale_denom))))) ->
                           (*      Post => Res <= Val;                                                                                                 *)
                           (*              ^ spark-mod_arithmetic_lemmas.ads:21:14:instantiated:spark-mod64_arithmetic_lemmas.ads:4:1:VC_POSTCONDITION *)
                           (ule res val__).
(* Why3 intros (h1,(h2,(h3,h4))). *)
intros (h1,(h2,(h3,h4))).
unfold ule.
unfold ule in h2.
unfold in_range in h1.
destruct h1.
unfold ule in H0.
unfold ule in H.
unfold ule in h3.
rewrite to_uint_of_int in H by auto with zarith.
pose (to_uint_bounds val__).
pose (to_uint_bounds scale_num).
pose (to_uint_bounds scale_denom).

case (Z.eq_dec (to_uint scale_num) 0%Z); intro.

(* case scale_num is zero *)
rewrite h4.
rewrite to_uint_udiv.
unfold EuclideanDivision.div.
case Z_le_dec; intro.
rewrite to_uint_mul.
rewrite BV_Gen.mod1_out.
rewrite e.
rewrite Z.mul_0_r.
unfold ule in H.
rewrite Z.div_0_l by auto with zarith.
easy.
rewrite e, Z.mul_0_r.
easy.
contradict n.
apply Z_mod_lt.
auto with zarith.

(* case scale_num is not zero *)
destruct h3.
rewrite H1, to_uint_of_int in n by auto with zarith.
contradict n; trivial.
rewrite h4.
rewrite to_uint_udiv.
unfold EuclideanDivision.div.
case Z_le_dec; intro.
rewrite to_uint_mul.
rewrite BV_Gen.mod1_out.

apply Int.Trans with (y := (to_uint val__ * to_uint scale_num / to_uint scale_num)%Z).
apply Z.div_le_compat_l; auto with zarith.
rewrite Z.div_mul by auto.
easy.

split.
auto with zarith.
rewrite to_uint_udiv in H1.
unfold EuclideanDivision.div in H1.
case Z_le_dec in H1.
rewrite to_uint_of_int in H1 by auto with zarith.
assert (0 <= to_uint scale_num)%Z as Scale_Num_Nat by auto with zarith.
pose (Int.CompatOrderMult (to_uint val__) (18446744073709551615 / to_uint scale_num) (to_uint scale_num) H1 Scale_Num_Nat).
replace (18446744073709551615 / to_uint scale_num * to_uint scale_num)%Z with (to_uint scale_num * (18446744073709551615 / to_uint scale_num))%Z in l1 by auto with zarith.
assert (0 < to_uint scale_num)%Z as Scale_Num_Pos by auto with zarith.
pose (Z.mul_div_le 18446744073709551615%Z (to_uint scale_num) Scale_Num_Pos).
auto with zarith.
contradict n0.
apply Z_mod_lt.
auto with zarith.
contradict n0.
apply Z_mod_lt.
auto with zarith.

Qed.


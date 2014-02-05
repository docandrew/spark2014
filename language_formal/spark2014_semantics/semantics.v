(** 
_AUTHOR_

<<
Zhi Zhang
Departmnt of Computer and Information Sciences
Kansas State University
zhangzhi@ksu.edu
>>
*)

Require Import LibTactics.
Require Export values.
Require Export environment.
Require Export util.
Require Export checks.

(** * Relational Semantics (big-step) *)
(** interpret the literal expressions *)
Definition eval_literal (l: literal): value :=
    match l with
    | Integer_Literal v => (Int v)
    | Boolean_Literal b => (Bool b)
    end.

(** interpret the binary operators *)
Inductive eval_bin_expr: binary_operator -> value -> value -> value -> Prop :=
    | Bin_Eq: forall v1 v2 b,
        Zeq_bool v1 v2 = b ->
        eval_bin_expr Equal (Int v1) (Int v2) (Bool b)
    | Bin_Ne: forall v1 v2 b,
        Zneq_bool v1 v2 = b ->
         eval_bin_expr Not_Equal (Int v1) (Int v2) (Bool b)
    | Bin_Gt: forall v1 v2 b,
        Zgt_bool v1 v2 = b ->
        eval_bin_expr Greater_Than (Int v1) (Int v2) (Bool b)
    | Bin_Ge: forall v1 v2 b,
        Zge_bool v1 v2 = b ->
        eval_bin_expr Greater_Than_Or_Equal (Int v1) (Int v2) (Bool b)
    | Bin_Lt: forall v1 v2 b,
        Zlt_bool v1 v2 = b ->
        eval_bin_expr Less_Than (Int v1) (Int v2) (Bool b)
    | Bin_Le: forall v1 v2 b,
        Zle_bool v1 v2 = b ->
        eval_bin_expr Less_Than_Or_Equal (Int v1) (Int v2) (Bool b)
    | Bin_And: forall v1 v2 b,
        andb v1 v2 = b ->
        eval_bin_expr And (Bool v1) (Bool v2) (Bool b)
    | Bin_Or: forall v1 v2 b,
        orb v1 v2 = b ->
        eval_bin_expr Or (Bool v1) (Bool v2) (Bool b)
    | Bin_Plus: forall v1 v2 v3,
        (v1 + v2)%Z =v3 ->
        eval_bin_expr Plus (Int v1) (Int v2) (Int v3)
    | Bin_Minus: forall v1 v2 v3,
        (v1 - v2)%Z =v3 ->
        eval_bin_expr Minus (Int v1) (Int v2) (Int v3)
    | Bin_Mul: forall v1 v2 v3,
        (v1 * v2)%Z =v3 ->
        eval_bin_expr Multiply (Int v1) (Int v2) (Int v3)
    | Bin_Div: forall v1 v2 v3,
        (Z.quot v1 v2)%Z =v3 ->
        eval_bin_expr Divide (Int v1) (Int v2) (Int v3).

(** interpret the unary operation *)
Inductive eval_unary_expr : unary_operator -> value -> value -> Prop :=
    | Unary_Not: forall b v,
        negb b = v ->
        eval_unary_expr Not (Bool b) (Bool v)
    | EUnary_Plus: forall v,
        eval_unary_expr Unary_Plus (Int v) (Int v).

Lemma eval_bin_unique: forall op v1 v2 x y,
    eval_bin_expr op v1 v2 x ->
    eval_bin_expr op v1 v2 y ->
    x = y.
Proof.
    intros.
    destruct op;
    inversion H; subst; inversion H0; subst;
    auto.
Qed.

Lemma eval_unary_unique: forall uop v x y,
    eval_unary_expr uop v x ->
    eval_unary_expr uop v y ->
    x = y.
Proof.
    intros.
    destruct uop;
    inversion H; subst; inversion H0; subst;
    auto.
Qed.


(** ** Expression semantics *)
(**
    for binary expression and unary expression, if a run time error 
    is detected in any of its child expressions, then return a run
    time error; for binary expression (e1 op e2), if both e1 and e2 
    are evaluated to some normal value, then run time checks are
    performed according to the checking rules specified for the 
    operator 'op', whenever the check fails (returning false), a run 
    time error is detected and the program is terminated, otherwise, 
    normal binary operation result is returned;
*)

Inductive eval_expr: stack -> expression -> Return value -> Prop :=
    | eval_E_Literal: forall l v s ast_num,
        eval_literal l = v ->
        eval_expr s (E_Literal ast_num l) (Normal v)
    | eval_E_Identifier: forall x s v ast_num,
        fetchG x s = Some (Value v) ->
        eval_expr s (E_Identifier ast_num x) (Normal v)
    | eval_E_Binary_Operation1: forall s e1 ast_num op e2,
        eval_expr s e1 Run_Time_Error ->
        eval_expr s (E_Binary_Operation ast_num op e1 e2) Run_Time_Error
    | eval_E_Binary_Operation2: forall s e1 v1 e2 ast_num op,
        eval_expr s e1 (Normal v1) ->
        eval_expr s e2 Run_Time_Error ->
        eval_expr s (E_Binary_Operation ast_num op e1 e2) Run_Time_Error
    | eval_E_Binary_Operation3: forall s e1 v1 e2 v2 ast_num op,
        eval_expr s e1 (Normal v1) ->
        eval_expr s e2 (Normal v2) ->
        do_check op v1 v2 false ->
        eval_expr s (E_Binary_Operation ast_num op e1 e2) Run_Time_Error
    | eval_E_Binary_Operation4: forall s e1 v1 e2 v2 ast_num op v,
        eval_expr s e1 (Normal v1) ->
        eval_expr s e2 (Normal v2) ->
        do_check op v1 v2 true ->
        eval_bin_expr op v1 v2 v ->
        eval_expr s (E_Binary_Operation ast_num op e1 e2) (Normal v)
    | eval_E_Unary_Operation1: forall s e ast_num op,
        eval_expr s e Run_Time_Error ->
        eval_expr s (E_Unary_Operation ast_num op e) Run_Time_Error
    | eval_E_Unary_Operation2: forall s e v ast_num op v1,
        eval_expr s e (Normal v) ->
        eval_unary_expr op v v1 ->
        eval_expr s (E_Unary_Operation ast_num op e) (Normal v1).




(** * Statement semantics *)

(** ** Stack manipulation for procedure calls and return *)

(** [Copy_out prefix lparams lexp s s'] means that s' is the result of
    copying Out params of the currently finished procedure of prefix
    into there output variables. More precisely:
  - [prefix] is the portion of the stack where parameters and local
    variables are stored
  - [lparams] is the static specification of the parameters of the
    procedure;
  - [lexp] is the original expression given as parameter of the
    procedure (this is where one can find the variables into
    performing the "out" operation;
  - [s] is the portion of the stack which needs to be updated and
    retruned, that is without local variables and parameters), more
    precisely, [prefix::s] is the state returned by the evaluation of
    the body of the procedure;
  - [s'] is the resulting state. *)
Inductive Copy_out: store -> list parameter_specification
                    -> list expression -> stack -> stack -> Prop :=
  Copy_out_nil : forall prf σ, Copy_out prf nil nil σ σ
| Copy_out_cons_out:
    forall σ σ' σ'' id v prf prm lprm lexp idorig astnum,
      prm.(parameter_mode) = Out
      -> id = prm.(parameter_name)
      -> fetch id prf = Some v
      -> updateG σ idorig v = Some σ'
      -> Copy_out prf lprm lexp σ' σ''
      -> Copy_out prf (prm::lprm) ((E_Identifier astnum idorig) :: lexp) σ σ''
| Copy_out_cons_in:
    forall σ σ'  prf prm lprm lexp e,
      prm.(parameter_mode) = In
      -> Copy_out prf lprm lexp σ σ'
      -> Copy_out prf (prm::lprm) (e :: lexp) σ σ'.

(** [Copy_in s lparams lexp frame] means the frame is the portion of
    the stack to push on the stack to start evaluating the procedure.
    More precisely, [frame] contains the value of the formal
    parameters described by [lpamrams]. these values are computed from
    the list of arguments [lexp]. Only "In" parameters are evaluated,
    "Out" parameters are set to [Undefined]. *)
Inductive Copy_in: stack -> list parameter_specification
                   -> list expression -> Return store -> Prop :=
  Copy_in_nil : forall σ, Copy_in σ nil nil (Normal nil) 
| Copy_in_cons_out:
    forall σ lparam lexp (frame:store) prm idv ast_num,
      Copy_in σ lparam lexp (Normal frame)
      -> prm.(parameter_mode) = Out
      -> Copy_in σ (prm::lparam) (E_Identifier ast_num idv::lexp)
                 (Normal ((prm.(parameter_name),Undefined)::frame))
| Copy_in_cons_out_rte:
    forall σ lparam lexp prm idv ast_num,
      Copy_in σ lparam lexp Run_Time_Error
      -> prm.(parameter_mode) = Out
      -> Copy_in σ (prm::lparam) (E_Identifier ast_num idv::lexp) Run_Time_Error
| Copy_in_cons_in_rte1:
    forall σ lparam lexp prm e,
      prm.(parameter_mode) = In
      -> eval_expr σ e Run_Time_Error
      -> Copy_in σ (prm::lparam) (e::lexp) Run_Time_Error
| Copy_in_cons_in_rte2:
    forall σ lparam lexp prm e v,
      Copy_in σ lparam lexp Run_Time_Error
      -> eval_expr σ e (Normal v)
      -> prm.(parameter_mode) = In
      -> Copy_in σ (prm::lparam) (e::lexp) Run_Time_Error
| Copy_in_cons_in:
    forall σ lparam lexp frame prm e v,
      Copy_in σ lparam lexp (Normal frame)
      -> prm.(parameter_mode) = In
      -> eval_expr σ e (Normal v)
      -> Copy_in σ (prm::lparam) (e::lexp)
                 (Normal ((prm.(parameter_name),Value v)::frame)).


(** *** Inductive semantic of declarations. [eval_decl s nil decl
        rsto] means that rsto is the frame to be pushed on s after
        evaluating decl, sto is used as an accumulator for building
        the frame.
 *)
Inductive eval_decl: stack -> store -> declaration -> Return store -> Prop :=
| eval_Decl_E:
    forall e d s sto,
      Some e = d.(initialization_expression) ->
      eval_expr (sto::s) e Run_Time_Error ->
      eval_decl s sto (D_Object_declaration d) Run_Time_Error
| eval_Decl:
    forall d x e v s sto,
      x = d.(object_name) ->
      Some e = d.(initialization_expression) ->
      eval_expr (sto::s) e (Normal v) ->
      eval_decl s sto (D_Object_declaration d) (Normal ((x, Value v) :: sto))
| eval_UndefDecl:
    forall d x s sto,
      x = d.(object_name) ->
      None = d.(initialization_expression) ->
      eval_decl s sto (D_Object_declaration d) (Normal ((x, Undefined) :: sto))
| eval_decl_Seq:
    forall dcl1 dcl2 s s' s'' sto,
      eval_decl s sto dcl1 (Normal s') ->
      eval_decl s s' dcl2 (Normal s'') ->
      eval_decl s sto (D_Sequence dcl1 dcl2) (Normal s'')
| eval_decl_Seq_err1:
    forall dcl1 dcl2 s sto,
      eval_decl s sto dcl1 Run_Time_Error ->
      eval_decl s sto (D_Sequence dcl1 dcl2) Run_Time_Error
| eval_decl_Seq_err2:
    forall dcl1 dcl2 s s' sto,
      eval_decl s sto dcl1 (Normal s') ->
      eval_decl s s' dcl2 Run_Time_Error ->
      eval_decl s sto (D_Sequence dcl1 dcl2) Run_Time_Error
| eval_decl_proc:
    forall s pbody sto,
      eval_decl s sto (D_Procedure_declaration pbody)
                (Normal ((procedure_name pbody,Procedure pbody)::sto)).

(** ** Inductive semantic of statement and declaration

   in a statement evaluation, whenever a run time error is detected in
   the evaluation of its sub-statements or sub-component, the
   evaluation is terminated and return a run time error; otherwise,
   evaluate the statement into a normal state.

 *)


Inductive eval_stmt: stack -> statement -> Return stack -> Prop := 
    | eval_S_Assignment1: forall s e ast_num x,
        eval_expr s e Run_Time_Error ->
        eval_stmt s (S_Assignment ast_num x e) Run_Time_Error
    | eval_S_Assignment2: forall s e v x s1 ast_num,
        eval_expr s e (Normal v) ->
        updateG s x (Value v) = Some s1 ->
        eval_stmt s (S_Assignment ast_num x e) (Normal s1)
    | eval_S_Sequence1: forall s c1 ast_num c2,
        eval_stmt s c1 Run_Time_Error ->
        eval_stmt s (S_Sequence ast_num c1 c2) Run_Time_Error
    | eval_S_Sequence2: forall ast_num s s1 s2 c1 c2,
        eval_stmt s c1 (Normal s1) ->
        eval_stmt s1 c2 s2 ->
        eval_stmt s (S_Sequence ast_num c1 c2) s2
    | eval_S_If: forall s b ast_num c,
        eval_expr s b Run_Time_Error ->
        eval_stmt s (S_If ast_num b c) Run_Time_Error
    | eval_S_If_True: forall s b c s1 ast_num,
        eval_expr s b (Normal (Bool true)) ->
        eval_stmt s c s1 ->
        eval_stmt s (S_If ast_num b c) s1
    | eval_S_If_False: forall s b ast_num c,
        eval_expr s b (Normal (Bool false)) ->
        eval_stmt s (S_If ast_num b c) (Normal s)
    | eval_S_While_Loop: forall s b ast_num c,
        eval_expr s b Run_Time_Error ->
        eval_stmt s (S_While_Loop ast_num b c) Run_Time_Error
    | eval_S_While_Loop_True1: forall s b c ast_num,
        eval_expr s b (Normal (Bool true)) ->
        eval_stmt s c Run_Time_Error ->
        eval_stmt s (S_While_Loop ast_num b c) Run_Time_Error
    | eval_S_While_Loop_True2: forall s b c s1 ast_num s2,
        eval_expr s b (Normal (Bool true)) ->
        eval_stmt s c (Normal s1) ->
        eval_stmt s1 (S_While_Loop ast_num b c) s2 ->
        eval_stmt s (S_While_Loop ast_num b c) s2
    | eval_S_While_Loop_False: forall s b ast_num c,
        eval_expr s b (Normal (Bool false)) ->
        eval_stmt s (S_While_Loop ast_num b c) (Normal s)
    | eval_S_Proc_rteargs:
        forall pbname (pb:procedure_body) lexp s ast_num,
          fetchG pbname s = Some (Procedure pb) ->
          Copy_in s (procedure_parameter_profile pb) lexp Run_Time_Error ->
          eval_stmt s (S_ProcCall ast_num pbname lexp) Run_Time_Error
    | eval_S_Proc_rtedecl:
        forall pbname (pb:procedure_body) lexp s_caller s_forget s ast_num prefix,
          fetchG pbname s_caller = Some (Procedure pb) ->
          Copy_in s_caller (procedure_parameter_profile pb) lexp (Normal prefix) ->
          Cut_until s_caller pbname s_forget s -> (* s_caller = s_forget++s *)
          eval_decl s prefix (procedure_declarative_part pb) Run_Time_Error ->
          eval_stmt s_caller (S_ProcCall ast_num pbname lexp) Run_Time_Error
    | eval_S_Proc_rtebody:
        forall pbname (pb:procedure_body) lexp s_caller s_forget s ast_num s2 prefix,
          fetchG pbname s_caller = Some (Procedure pb) ->
          Copy_in s_caller (procedure_parameter_profile pb) lexp (Normal prefix) ->
          Cut_until s_caller pbname s_forget s -> (* s_caller = s_forget++s *)
          eval_decl s prefix (procedure_declarative_part pb) (Normal s2) ->
          eval_stmt (s2::s) (procedure_statements pb) Run_Time_Error ->
          eval_stmt s_caller (S_ProcCall ast_num pbname lexp) Run_Time_Error
    | eval_S_Proc:
        forall pbname (pb:procedure_body) lexp s_caller s_forget s ast_num
               s2 s3 s' s'' slocal prefix prefix',
          fetchG pbname s_caller = Some (Procedure pb) ->
          Copy_in s_caller (procedure_parameter_profile pb) lexp (Normal prefix) ->
          Cut_until s_caller pbname s_forget s -> (* s_caller = s_forget++s *)
          eval_decl s prefix (procedure_declarative_part pb) (Normal s2) ->          
          eval_stmt (s2::s) (procedure_statements pb) (Normal s3) ->
          s3 = (slocal ++ prefix') :: s' -> (* extract parameters from local frame *)
          List.length prefix = List.length prefix' ->
          Copy_out prefix' (procedure_parameter_profile pb) lexp (s_forget++s') s'' ->
          eval_stmt s_caller (S_ProcCall ast_num pbname lexp) (Normal s'')
.


(** ** examples *)

Module ExampleProcedures.
(* EXAMPLE 1, v102 is a variable in the scope.
------------------------
procedure P2 () is
  V4 : TYPE5 := 34;
begin
  V102 := 56;
end 
-----------------------
*)
Definition proc1:procedure_body := (mkprocedure_body
           1 101 nil nil
             (D_Object_declaration
                {|
                  declaration_astnum := 3;
                  object_name := 4;
                  object_nominal_subtype :=  5;
                  initialization_expression := Some (E_Literal 6 (Integer_Literal(34)))
                |}
             )
             (S_Assignment 12 102 (E_Literal 8 (Integer_Literal(56))))).

Definition s1:stack := ((101,Procedure proc1) :: (102, Value (Int(77))) :: nil)::nil.

Definition s2:stack := ((101,Procedure proc1) :: (102, Value (Int(56)))  :: nil)::nil.


Lemma essai: eval_stmt s1 (S_ProcCall 13 101 nil) (Normal s2).
Proof.
  eapply eval_S_Proc; try now (simpl; eauto).
  - simpl.
    instantiate (1 := nil).
    constructor.
  - constructor 1.
    reflexivity.
    
  - econstructor 2.
    + reflexivity.
    + simpl.
      reflexivity.
    + constructor.
      simpl.
      reflexivity.
  - simpl.
    econstructor.
    + econstructor.
      simpl.
      eauto.
    + simpl.
      rewrite app_nil_r.
      reflexivity.
  - simpl.
    constructor 1.
Qed.



(* v102 is a variable in the scope.
procedure P2 () is
  V4 : TYPE5 := 34;
  V5 : TYPE5 := 37;
begin
  V5 := V4 + V5;
  V102 := V5*2;
end 
*)
Definition proc2:procedure_body := (mkprocedure_body
           1 101 nil nil
             (D_Sequence
                (D_Object_declaration
                   {|
                     declaration_astnum := 3;
                     object_name := 4;
                     object_nominal_subtype :=  5;
                     initialization_expression := Some (E_Literal 6 (Integer_Literal(34)))
                   |}
                )
                (D_Object_declaration
                   {|
                     declaration_astnum := 4;
                     object_name := 5;
                     object_nominal_subtype :=  5;
                     initialization_expression := Some (E_Literal 6 (Integer_Literal(37)))
                   |}
                )
             )
             (S_Sequence 13
                (S_Assignment 14 5
                              (E_Binary_Operation 9 Plus
                                                  (E_Identifier 10 5)
                                                  (E_Identifier 10 4)))
                (S_Assignment
                   12
                   102
                   (E_Binary_Operation 9 Multiply
                                       (E_Identifier 10 5)
                                       (E_Literal 8 (Integer_Literal(2))))))).

Definition sto3:store := (101,Procedure proc2) :: (102, Value (Int(77))) :: nil.

Definition sto4:store := (101,Procedure proc2) :: (102, Value (Int(142)))  :: nil.



Lemma essai2: eval_stmt (sto3::nil) (S_ProcCall 13 101 nil) (Normal (sto4::nil)).
Proof.
  eapply eval_S_Proc; try now (simpl; eauto).
  - simpl.
    constructor.
  - constructor 1.
    reflexivity.
  - 
(*     instantiate (1:= ((5, Value (Int 37))::(4, Value (Int 34))::s3)). *)
    unfold sto3, sto4, proc1.
    simpl.
    econstructor 4;simpl.
    + econstructor 2;simpl.
      * econstructor;eauto.
      * reflexivity.
      * constructor.
        simpl.
        reflexivity.
    + econstructor 2;simpl.
      * econstructor;eauto.
      * reflexivity.
      * constructor.
        simpl.
        reflexivity.
  - simpl.
    + { econstructor.
        - econstructor.
          + econstructor.
            * econstructor.
              simpl.
              eauto.
            * constructor.
              simpl.
              eauto.
            * constructor.
              vm_compute.
              reflexivity.
            * econstructor.
              simpl.
              eauto.
          + simpl.
            reflexivity.
        - econstructor.
          + econstructor.
            * econstructor.
              simpl.
              eauto.
            * econstructor.
              simpl.
              eauto.
            * econstructor.
              vm_compute.
              reflexivity.
            * econstructor.
            simpl.
            eauto.
        + simpl.
          rewrite app_nil_r.
          reflexivity. }
  - simpl.
    constructor 1.
Qed.


End ExampleProcedures.
(* END EXAMPLE *)  

(** ** Functional Semantics of expressions *)

(** for relational semantics of expression and statement, we also 
    provide its corresponding version of functional semantics, and 
    prove that they are semantics equivalent;
    relational semantics encode the formal semantics rules, while
    functional semantics is useful to familiarize oneself with the 
    SPARK 2014 semantics, and validate it experimentally by testing, 
    and it also helps to fix the program if the program exhibits 
    undefined behavior;
    
    Bisimulation between relational and functional semantics are
    proved for the following pairs of evaluations: 
    
    - f_eval_binexpr <-> eval_binexpr;
    
    - f_eval_unaryexpr <-> eval_unaryexpr;
    
    - f_eval_expr <-> eval_expr;

    - f_eval_stmt <-> eval_stmt;
*)

(** *** semantic of operators *)

(** interpret the binary operation for each binary operator *)
Definition f_eval_bin_expr (op: binary_operator) (v1: value) (v2: value): Return value :=
    match op with
    | Equal => Val.eq v1 v2
    | Not_Equal => Val.ne v1 v2
    | Greater_Than => Val.gt v1 v2
    | Greater_Than_Or_Equal => Val.ge v1 v2
    | Less_Than => Val.lt v1 v2
    | Less_Than_Or_Equal => Val.le v1 v2
    | And => Val.and v1 v2
    | Or => Val.or v1 v2
    | Plus => Val.add v1 v2
    | Minus => Val.sub v1 v2
    | Multiply => Val.mul v1 v2
    | Divide => Val.div v1 v2
    end.

(** interpret the unary operation *)
Definition f_eval_unary_expr (op: unary_operator) (v: value): Return value :=
    match op with
    | Not => Val.not v
    | Unary_Plus => Val.unary_add v
    end.

(** *** Expression semantics *)

(** in functional semantics for expression, it returns either a
    normal value or a run time error or go abnormal, the run time 
    checks (for example, division by zero check) are encoded inside 
    the semantics; *)
Function f_eval_expr (s: stack) (e: expression): Return value :=
    match e with
    | E_Literal _ v => Normal (eval_literal v)
    | E_Identifier _ x =>
        match (fetchG x s) with
        | Some (Value v) => Normal v
        | _ => Abnormal (* None or procedure *)
        end
    | E_Binary_Operation _ op e1 e2 =>
        match f_eval_expr s e1 with
        | Normal v1 => 
            match f_eval_expr s e2 with
            | Normal v2 => 
                match f_do_check op v1 v2 with
                | Some true => f_eval_bin_expr op v1 v2
                | Some false => Run_Time_Error
                | _ => Abnormal
                end
            | Run_Time_Error => Run_Time_Error
            | Abnormal => Abnormal
            | Unterminated => Unterminated
            end
        | Run_Time_Error => Run_Time_Error
        | Abnormal => Abnormal
        | Unterminated => Unterminated
        end   
    | E_Unary_Operation _ op e => 
        match f_eval_expr s e with
        | Normal v => f_eval_unary_expr op v
        | Run_Time_Error => Run_Time_Error
        | Abnormal => Abnormal
        | Unterminated => Unterminated
        end
    end.

(** ** Functional Statement semantics *)


(** *** Functional manipulation of the stack for procedure call and
    retrun *)

(** functional version of Copy_out
  [copy_out prefx params lexp s'] returns s' updated in the following
  way: for each param in params that is Out, pick the correponding
  variable name in lexp and update s' with the value of the param that
  is stored in prefix. *)
Function copy_out (prefx:store) (params: list parameter_specification)
         (lexp:list expression) (s: stack) {struct params}:  Return stack :=
  match params, lexp with
    | nil , nil => Normal s
    | (prm::params') , (e::lexp') =>
      match prm.(parameter_mode) with
         | Out =>
           match e with
             | E_Identifier _ x =>
               match (fetch (prm.(parameter_name)) prefx) with
                   Some v =>
                   match updateG s x v with
                     | Some s' => copy_out prefx params' lexp' s'
                     | None => Abnormal
                   end
                 | None => Abnormal
               end
             | _ => Abnormal
           end
         | In => copy_out prefx params' lexp' s
         | _ => Abnormal
       end
    | _ , _ => Abnormal
  end.

(** Functional version of Copy_in.
   [copy_in s lparams lexp] returns the prefix to push on the stack
   before evaluationg procedure body (i.e. declaration block +
   statement). "Out" parameters values are copied into there output
   variables (stored in lexp). *)
Function copy_in (s:stack) lparams lexp: Return store :=
  match lparams,lexp with
  | (prm :: lparams') , (exp:: lexp') =>
    match prm.(parameter_mode) with
      | Out => if is_var exp
               then match copy_in s lparams' lexp' with
                      | Normal res => Normal ((prm.(parameter_name), Undefined) :: res)
                      | res => res
                    end
               else Abnormal
      | In =>
        let v := f_eval_expr s exp in
        match v with
          | Normal v' =>
            match copy_in s lparams' lexp' with
              | Normal res => Normal ((prm.(parameter_name), Value v') :: res)
              | res => res
            end
          | Run_Time_Error => Run_Time_Error
          | Abnormal => Abnormal
          | Unterminated => Unterminated
        end
      | In_Out => Abnormal (* not yet implemented *)
    end
  | nil , nil => Normal nil
  | _ , _ => Abnormal
  end.

(** *** functional semantic of declarations *)

Function f_eval_decl (s: stack) (sto:store) (c: declaration) {struct c}: Return store :=
  match c with
    | D_Object_declaration d =>
      match d.(initialization_expression) with
        | Some e =>
          match f_eval_expr (sto::s) e with
            | Run_Time_Error => Run_Time_Error
            | Normal v =>
              (Normal ((d.(object_name), Value v)::sto))
            | Abnormal => Abnormal
            | Unterminated => Unterminated
          end
        | None => (Normal ((d.(object_name), Undefined) :: sto))
      end
    | D_Sequence dcl1 dcl2 =>
      match f_eval_decl s sto dcl1 with
        | Normal s' => f_eval_decl s s' dcl2
        | err => err
      end
    | D_Procedure_declaration pbody =>
      Normal((procedure_name pbody,Procedure pbody)::sto)
  end.

(** *** functional semantic of statements *)

(** 
   in the functional semantics for statement, 'k' denotes the execution 
   steps, whenever it reaches 0, an untermination state is returned;
   otherwise, it returns either a normal state, or a run time error 
   or an abnormal state; run time checks (for example, division by 
   zero check) are encoded inside the functional semantics;
*)





Function f_eval_stmt k (s: stack) (c: statement) {struct k}: Return stack := 
  match k with
  | 0 => Unterminated
  | S k' => 
    match c with
    | S_Assignment ast_num x e =>
        match f_eval_expr s e with
        | Normal v => 
            match updateG s x (Value v) with
            | Some s1 => Normal s1
            | None => Abnormal
            end
        | Run_Time_Error => Run_Time_Error
        | Abnormal => Abnormal
        | Unterminated => Unterminated
        end
    | S_Sequence ast_num c1 c2 =>
        match f_eval_stmt k' s c1 with
        | Normal s1 => f_eval_stmt k' s1 c2
        | Run_Time_Error => Run_Time_Error
        | Unterminated => Unterminated
        | Abnormal => Abnormal
        end
    | S_If ast_num b c =>
        match f_eval_expr s b with
        | Normal (Bool true) => f_eval_stmt k' s c
        | Normal (Bool false) => Normal s
        | Run_Time_Error => Run_Time_Error
        | Unterminated => Unterminated
        | _ => Abnormal
        end
    | S_While_Loop ast_num b c => 
        match f_eval_expr s b with
        | Normal (Bool true) => 
            match f_eval_stmt k' s c with
            | Normal s1 => f_eval_stmt k' s1 (S_While_Loop ast_num b c)
            | Run_Time_Error => Run_Time_Error
            | Unterminated => Unterminated
            | Abnormal => Abnormal
            end
        | Normal (Bool false) => Normal s
        | Run_Time_Error => Run_Time_Error
        | Unterminated => Unterminated
        | _ => Abnormal
        end
    | S_ProcCall ast_num pbname lexp =>
      match fetchG pbname s with
        | Some (Procedure pb) => 
          match copy_in s (procedure_parameter_profile pb) lexp with
            | Normal prefx => 
              match cut_until s pbname with
                | Some (s_forget, s_called) =>
                  match f_eval_decl s_called prefx (procedure_declarative_part pb) with
                    | Normal s2 =>
                      match f_eval_stmt k' (s2::s_called) (procedure_statements pb) with
                        | Normal (frame::s') =>
                          match split1 _ (List.length frame - List.length prefx) frame with
                            | Some (slocal,prefx') =>
                              (copy_out prefx' (procedure_parameter_profile pb) lexp (s_forget++s'))
                            | None => Abnormal (* erronous store size *)
                          end
                        | Run_Time_Error => Run_Time_Error
                        | _ => Abnormal (* erronous stack size or abnormal result *)
                      end
                    | Run_Time_Error => Run_Time_Error
                    | _ => Abnormal
                  end
                | None => Abnormal (* procedure doesn't exist *)
              end
            (* left and right are not of the same type (return_state
               store) and (return_state stack) *)
            | Run_Time_Error => Run_Time_Error
            | Abnormal => Abnormal
            | Unterminated => Unterminated
          end
        | _ => (* None or non-procedure *) Abnormal
      end
    end
  end.


(** basic lemmas *)
(** expression semantic is deterministic. *)

Lemma eval_expr_unique: forall s e v1 v2,
    eval_expr s e v1 ->
    eval_expr s e v2 ->
    v1 = v2.
Proof.
  intros s e v1 v2 H.
  revert v2.
  induction H;intros v' h;try now (inversion h;clear h;subst;try auto).
  - (inversion h;clear h;subst;try auto).
    rewrite H in H4.
    injection H4.
    intros H0.
    subst.
    auto.

  - (inversion h;clear h;subst;try auto).
    apply IHeval_expr in H5.
    discriminate.
    
  - (inversion h;clear h;subst;try auto).
    apply IHeval_expr2 in H8.
    discriminate.

  - (inversion h;clear h;subst;try auto).
    apply f_do_check_complete in H10.
    apply f_do_check_complete in H1.
    apply IHeval_expr2 in H9.
    apply IHeval_expr1 in H7.
    injection H7.
    injection H9.
    intros; subst.
    rewrite H10 in H1.
    discriminate.

  - (inversion h;clear h;subst;try auto).
    + apply IHeval_expr1 in H9.
      discriminate.
    + apply IHeval_expr2 in H10.
      discriminate.

    + apply f_do_check_complete in H11.
      apply f_do_check_complete in H1.
      apply IHeval_expr1 in H9.
      apply IHeval_expr2 in H10.
      injection H9.
      injection H10.
      intros; subst.
      rewrite H11 in H1.
      discriminate.

    + apply IHeval_expr1 in H8.
      apply IHeval_expr2 in H10.
      injection H8.
      injection H10.
      intros ;subst.
      rewrite (eval_bin_unique _ _ _ _ _ H12 H2) .
      reflexivity.
    
  - (inversion h;clear h;subst;try auto).
    apply IHeval_expr in H5.
    discriminate.
  - (inversion h;clear h;subst;try auto).
    + apply IHeval_expr in H6.
      discriminate.
    + apply IHeval_expr in H6.
      injection H6.
      intros ;subst.
      rewrite (eval_unary_unique _ _ _ _ H7 H0) .
      reflexivity.
Qed.    


(** 
    for any expression e evaluated under the state s, if it can be 
    evaluated to a value v with respect to the relational semantics 
    eval_expr, then the result value v should be either a normal 
    value or a run time error;
*)
Lemma eval_expr_state : forall s e v,
        eval_expr s e v -> (* v should be either a normal value or a run time error *)
            (exists v0, v = Normal v0) \/ v = Run_Time_Error.
Proof.
    intros s e v h.
    induction h;
    try match goal with
    | [ |- (exists v, Normal ?v1 = Normal v) \/ _ ]
      => left; exists v1; reflexivity
    | [ |- context [ _ \/ ?A = ?A ] ] => right; reflexivity
    end; auto.
Qed.

(** 
    for any statement c starting from the initial state s, if it 
    terminates in a state s' with respect to the relational semantics 
    eval_stmt, then the result state s' should be either a normal 
    state or a run time error. In relational semantics eval_stmt, 
    all statements that can go abnormal are excluded;
*)
Lemma eval_stmt_state : forall s c s',
        eval_stmt s c s' -> (* s' is either a normal state or a run time error *)
            (exists v, s' = Normal v) \/ s' = Run_Time_Error.
Proof.
    intros s c s' h.
    induction h;
    try match goal with
    | [ |- (exists v, Normal ?v1 = Normal v) \/ _ ] => left; exists v1; reflexivity
    | [ |- context [ _ \/ ?A = ?A ] ] => right; reflexivity
    end; auto.
Qed.

(** * Bisimulation Between Relational And Functional Semantics *)

(** bisimulation proof between f_eval_binexpr and eval_binexpr:
    - f_eval_bin_expr_correct
    - f_eval_bin_expr_complete
*)
Lemma f_eval_bin_expr_correct: forall op v1 v2 v,
    f_eval_bin_expr op v1 v2 = Normal v ->
    eval_bin_expr op v1 v2 v.
Proof.
    intros op v1 v2 v h1.
    destruct op;
    match goal with 
    |[|- eval_bin_expr Divide _ _ _] => idtac
    |[|- eval_bin_expr ?op _ _ _] =>
        destruct v1, v2;
        simpl in h1; inversion h1; subst;
        constructor; auto
    end.
    destruct v1, v2; simpl in h1; inversion h1.
    constructor.
    remember (Zeq_bool n0 0) as x.
    reflexivity.
Qed.

Lemma f_eval_bin_expr_complete: forall op v1 v2 v,
    eval_bin_expr op v1 v2 v ->
    f_eval_bin_expr op v1 v2 = Normal v.
Proof.
    intros op v1 v2 v h1.
    induction h1;
    rewrite <- H;
    simpl; auto.
Qed.

(** bisimulation proof between f_eval_unaryexpr and eval_unaryexpr: 
    - f_eval_unary_expr_correct
    - f_eval_unary_expr_complete
*)
Lemma f_eval_unary_expr_correct: forall op v v',
    f_eval_unary_expr op v = Normal v' ->
    eval_unary_expr op v v'.
Proof.
    intros.
    destruct op; simpl in H.
    - destruct v; inversion H; subst.
      constructor; auto.
    - destruct v;destruct v';simpl in *;try discriminate.
      injection H.
      intro.
      subst.
      constructor 2.      
Qed.

Lemma f_eval_unary_expr_complete: forall op v v',
    eval_unary_expr op v v' ->
    f_eval_unary_expr op v = Normal v'.
Proof.
  intros op v v' h1.
  induction h1;simpl;subst;auto.
Qed.

(** ** Bisimulation between f_eval_expr and eval_expr for expression Semantics *)
(** a help lemma to prove the theorem: f_eval_expr_correct *)
Lemma f_eval_expr_correct1 : forall s e v,
                        f_eval_expr s e = Normal v ->
                            eval_expr s e (Normal v).
Proof.
    intros s e.
    functional induction (f_eval_expr s e);
    intros v0 h1;
    try inversion h1; subst.
  - constructor;
    reflexivity.
  - constructor;
    assumption.
  - specialize (IHr _ e3).
    specialize (IHr0 _ e4).
    rewrite H0.
    econstructor.
    exact IHr. exact IHr0.
    + apply f_do_check_correct.
      auto.
    + apply f_eval_bin_expr_correct; 
      auto.
  - specialize (IHr _ e2).
    rewrite h1.
    econstructor. 
    exact IHr.
    destruct op. 
    + simpl in h1. 
      destruct v; inversion h1; subst.
      constructor; auto.
    + simpl in h1. 
      destruct v; inversion h1; subst.
      constructor; auto.
Qed.

(** another help lemma to prove the theorem: f_eval_expr_correct *)
Lemma f_eval_expr_correct2 : forall s e,
                        f_eval_expr s e = Run_Time_Error ->
                            eval_expr s e Run_Time_Error.
Proof.
    intros s e.
    functional induction (f_eval_expr s e);
    intros h; try inversion h.
  - destruct op, v1, v2;
    simpl in h; inversion h.
  - specialize (f_eval_expr_correct1 _ _ _ e3); intros hz1.
    specialize (f_eval_expr_correct1 _ _ _ e4); intros hz2.
    eapply eval_E_Binary_Operation3.
    apply hz1. apply hz2.
    apply f_do_check_correct; auto.
  - specialize (f_eval_expr_correct1 _ _ _ e3); intros hz1.
    specialize (IHr0 e4).
    eapply eval_E_Binary_Operation2; auto.
    exact hz1.
  - specialize (IHr e3).
    constructor; assumption.
  - destruct op;
    destruct v; inversion h. 
  - specialize (IHr e2).
    constructor; assumption.
Qed.

(** *** f_eval_expr_correct *)
(** 
    for an expression e evaluated under the state s with respect to
    the functional semantics f_eval_expr, whenever it returns a 
    normal value v or terminates in a run time error, 
    the relation between s, e and evaluation result should also be 
    satisfied with respect to the relational semantics 'eval_expr';
*)
Theorem f_eval_expr_correct : forall s e v,
                        (f_eval_expr s e = Normal v ->
                            eval_expr s e (Normal v)) /\
                        (f_eval_expr s e = Run_Time_Error ->
                            eval_expr s e Run_Time_Error).
Proof.
    split.
  - apply f_eval_expr_correct1.
  - apply f_eval_expr_correct2.
Qed.


(** *** f_eval_expr_complete *)
(** 
   for any expression e, if it can be evaluated to a value v under
   state s with respect to the relational semantics 'eval_expr', 
   then when we evalute e under the same state s in functional
   semantics 'f_eval_expr', it should return the same result v;
*)
Theorem f_eval_expr_complete : forall e s v,  
                        eval_expr e s v -> 
                            (f_eval_expr e s) = v.
Proof.
    intros e s v h.
    induction h; simpl; intros;
    repeat match goal with
    | h: fetchG _ _ = _  |- _ => progress rewrite h
    | h: f_eval_expr _ _ = _ |- _ => progress rewrite h
    end;auto.
  - rewrite H; reflexivity.
  - specialize (f_do_check_complete _ _ _ _ H); intros hz1.
    rewrite hz1.
    reflexivity.
  - destruct v1; destruct v2;
    destruct op;
    inversion H0; subst; simpl; auto.
    + (* overflow check for Plus *)
      inversion H; subst.
      rewrite H3; auto.
      unfold not in H2; intuition.
    + (* overflow check for Minus *)
      inversion H; subst.
      rewrite H3; auto.
      unfold not in H2; intuition.
    + (* overflow check for Multiply *)
      inversion H; subst.
      rewrite H3; auto.
      unfold not in H2; intuition.
    + (* both division by zero check and overflow check *)
      inversion H; subst.
      rewrite H3; auto.
      rm_false_hyp.
  - destruct op.
    + inversion H; subst.
      auto.
    + inversion H; subst.
      auto.
Qed.



Ltac discriminate2 :=
  let rewd HH HH' y z :=
      match y with 
        | z => fail 
        | _ => rewrite HH in HH';discriminate
  end in
    match goal with
      | HH: ?x = ?y , HH': ?x = ?z |- _ => rewd HH HH' y z
      | HH: ?x = ?y , HH': ?z = ?x |- _ => rewd HH HH' y z 
      | HH: ?y = ?x , HH': ?x = ?z |- _ => symmetry in HH; rewd HH HH' y z
      | HH: ?y = ?x , HH': ?z = ?x |- _ => symmetry in HH; rewd HH HH' y z
    end.



Ltac apply_inv :=
  try discriminate; try discriminate2;
  match goal with
    | H:Normal _ = Normal _ |- _ => inversion H;clear H;subst 
    | H:update _ _ (Value _) = _ |- _ => rewrite H
    | H:updateG _ _ (Value _) = _ |- _ => rewrite H
    | H:f_eval_stmt _ _ _ = _ |- _ => rewrite H
    | H:f_eval_expr _ _ = _ |- _ => rewrite H
    | H:f_eval_decl _ _ _ = _ |- _ => rewrite H
    | H:copy_out _ _ _ _ = _ |- _ => rewrite H
    | H:copy_in _ _ _ = _ |- _ => rewrite H
    | H:fetch _ _ = _ |- _ => rewrite H
    | H:fetchG _ _ = _ |- _ => rewrite H
    | H:split2 _ _ _ = _ |- _ => rewrite H
    | H:split1 _ _ _ = _ |- _ => rewrite H
    | H:cut_until _ _ = _ |- _ => rewrite H
  end;subst;simpl;auto.

Ltac invle := match goal with
    | H: (S _ <= _)%nat |- _ => (inversion H; clear H; subst; simpl)
  end.

(** a help lemma to prove the theorem: 'f_eval_stmt_complete',
    it means that: for any statement c, starting from initial state s, 
    if it terminates in a normal state s' within k execution steps, 
    then for any k' greater and equal than k, it should also terminate 
    in the same state s';
*)
Lemma f_eval_stmt_fixpoint: forall k s c s', 
        f_eval_stmt k s c = Normal s' ->
        forall k':nat, (k <= k')%nat -> 
            f_eval_stmt k' s c = Normal s'.
Proof.
    intros k s c.
    functional induction (f_eval_stmt k s c); simpl; intros; subst; simpl; auto;
    repeat progress apply_inv.
  - invle; repeat apply_inv.
  - invle.
    + repeat apply_inv.
    + rewrite (IHr _ e1);auto with arith.
  - invle; repeat apply_inv. rewrite (IHr _ H);auto with arith.
  - invle; repeat apply_inv.
  - invle; repeat apply_inv. rewrite (IHr _ e2); auto with arith.
  - invle; repeat apply_inv.
  - invle; repeat apply_inv.
    + rewrite (IHr _ e5).
      repeat apply_inv.
      auto with arith.
Qed.

(** another help lemma to prove the theorem: 'f_eval_stmt_complete' *)
Lemma f_eval_stmt_fixpoint_E: forall k s p, 
        f_eval_stmt k s p = Run_Time_Error ->
        forall k':nat, (k <= k')%nat -> 
            f_eval_stmt k' s p = Run_Time_Error.
Proof.
    intros k s p.
    functional induction (f_eval_stmt k s p); simpl; intros; subst; simpl; auto;
    repeat progress apply_inv. 
  - invle;
    apply_inv.
  - invle;
    repeat apply_inv.
    rewrite (f_eval_stmt_fixpoint _ _ _ _ e1); auto with arith.
  - invle;
    repeat apply_inv.
    specialize (IHr e1). 
    rewrite IHr; auto with arith. 
  - invle; 
    repeat apply_inv.
    rewrite IHr; auto with arith.
  - invle;
    repeat apply_inv.
  - invle; 
    repeat apply_inv. 
    rewrite (f_eval_stmt_fixpoint _ _ _ _ e2); auto with arith.
  - invle; 
    repeat apply_inv.
    rewrite (IHr e2); auto with arith.    
  - invle; 
    repeat apply_inv.   
  - invle; repeat apply_inv.
    rewrite (f_eval_stmt_fixpoint _ _ _ _ e5); auto with arith.
    rewrite e6.
    assumption.
  - invle; repeat apply_inv.
    rewrite  (IHr e5 m);auto with arith.
  - clear H.
    invle; repeat apply_inv.
  - invle; repeat apply_inv.
Qed.


Ltac destrIH :=
  repeat progress (match goal with
                     | h: ex _ |- _  =>
                       let k := fresh "k" in
                       let hk1 := fresh "hk" in
                       destruct (h) as [k hk1];try assumption
                   end).

Ltac kgreater :=
  repeat
    match goal with
      | h:f_eval_stmt ?k ?s ?p = Normal ?s' |- context [f_eval_stmt (?k + _) ?s ?p] =>
        rewrite (@f_eval_stmt_fixpoint _ _ _ _ h);auto with arith
      | h:f_eval_stmt ?k ?s ?p = Normal ?s' |- context [f_eval_stmt (_ + ?k) ?s ?p] =>
        rewrite (@f_eval_stmt_fixpoint _ _ _ _ h);auto with arith
      | h:f_eval_stmt ?k ?s ?p = Run_Time_Error |- context [f_eval_stmt (?k + _) ?s ?p] =>
        rewrite (@f_eval_stmt_fixpoint_E _ _ _ h);auto with arith
      | h:f_eval_stmt ?k ?s ?p = Run_Time_Error |- context [f_eval_stmt (_ + ?k) ?s ?p] =>
        rewrite (@f_eval_stmt_fixpoint_E _ _ _ h);auto with arith
         end.


Ltac rm_eval_expr :=
  match goal with 
    | [ h: eval_expr ?s ?b ?X, h': f_eval_expr ?s ?b = ?X |- _ ] => clear h
    | [ h: eval_expr ?s ?b ?X, h': ?X = f_eval_expr ?s ?b |- _ ] => clear h; symmetry in h'
    | [ h: eval_expr ?s ?b ?X |- _ ] => apply f_eval_expr_complete in h
  end; auto.


Ltac rewinv h h' := rewrite h in h'; inversion h'; try clear h' ; subst.

(* This tactic is a generalization of inversion. We first rewrite with
   some equality about function f first, and then do inversion on the
   rewritten hypothesis. The tactic removes the inversed hypothesis at
   the end so this *should* never loop. *)
Ltac inversion2 f :=
  match goal with
    | H: f ?X = _ , H': context [f ?X] |- _ => rewinv H H'
    | H: f ?X ?Y = _ , H': context [ f ?X ?Y ] |- _ => rewinv H H'
    | H: f ?X ?Y ?Z = _ , H': context [ f ?X ?Y ?Z ] |- _ => rewinv H H'
    | H: f ?X ?Y ?Z ?U = _ , H': context [ f ?X ?Y ?Z ?U ] |- _ => rewinv H H'
    | H: f ?X ?Y ?Z ?U ?V = _ , H': context [ f ?X ?Y ?Z ?U ?V ] |- _ => rewinv H H'
    | H: f ?X ?Y ?Z ?U ?V ?W = _ , H': context [ f ?X ?Y ?Z ?U ?V ?W ] |- _ => rewinv H H'
    (* Same with a left to right equality *)
    | H: _ = f ?X , H': context [f ?X] |- _ => rewinv H H'
    | H: _ = f ?X ?Y , H': context [ f ?X ?Y ] |- _ => rewinv H H'
    | H: _ = f ?X ?Y ?Z , H': context [ f ?X ?Y ?Z ] |- _ => rewinv H H'
    | H: _ = f ?X ?Y ?Z ?U , H': context [ f ?X ?Y ?Z ?U ] |- _ => rewinv H H'
    | H: _ = f ?X ?Y ?Z ?U ?V , H': context [ f ?X ?Y ?Z ?U ?V ] |- _ => rewinv H H'
    | H: _ = f ?X ?Y ?Z ?U ?V ?W , H': context [ f ?X ?Y ?Z ?U ?V ?W ] |- _ => rewinv H H'
  end ; auto.



Lemma copy_in_correct:
  forall s prm lexp prefx,
    copy_in s prm lexp = (Normal prefx) <->  Copy_in s prm lexp (Normal prefx).
Proof.
  intros s prm lexp.
  functional induction copy_in s prm lexp;intros;split;simpl in *;intro heq
  ; try (inversion heq;subst;clear heq)
  ; repeat rm_eval_expr
  ; try repeat progress match goal with (* Rewrite induction hyp if you can *)
                          | H: (forall _, ?X = _ <-> _)  |- _ =>
                            rewrite <- H in *
                        end
  ; try (now repeat progress
             first [ discriminate2
                   | inversion2 copy_in;auto
                   | inversion2 f_eval_expr;auto ]).
  - inversion_is_var e2.
    econstructor 2.
    + apply IHr;auto.
    + assumption.

  - apply Copy_in_cons_in.
    + apply IHr.
      assumption.
    + assumption.
    + apply f_eval_expr_correct1.
      assumption.
  - constructor 1.
Qed.



Lemma copy_in_correct2:
  forall s prm lexp,
    copy_in s prm lexp = Run_Time_Error <->  Copy_in s prm lexp Run_Time_Error.
Proof.
  intros s prm lexp.
  functional induction copy_in s prm lexp;intros;split;simpl in *;intro heq
  ; try (inversion heq;subst;clear heq)
  ; repeat try rm_eval_expr
  ; try repeat progress (* Rewrite with induction hyp as much as we can *)
        match goal with
          | H: (?X = _ <-> _)  |- _ =>
            rewrite <- H in *
        end
  ; try (now repeat progress
             first [ discriminate2
                   | inversion2 copy_in;auto
                   | inversion2 f_eval_expr;auto ]).
  - inversion_is_var e2.
    rewrite H0.
    econstructor;auto.
    rewrite <- IHr.
    assumption.
  - rewrite H0.
    apply Copy_in_cons_in_rte2 with (v:=v');auto.
    + rewrite <- IHr.
      assumption.
    + apply f_eval_expr_correct1.
      assumption.
  - apply Copy_in_cons_in_rte1;auto.
    apply f_eval_expr_correct2.
    assumption.
Qed.

Lemma Copy_out_stack_eq_length :
  forall prefx prm lexp s s',
    Copy_out prefx prm lexp s s'
    -> stack_eq_length s s'.
Proof.
  intros prefx prm lexp s s' H.
  induction H;auto.
  - apply stack_eq_length_refl.
    reflexivity.
  - apply updateG_stack_eq_length in H2.
    apply stack_eq_length_trans with σ';auto.
Qed.

Lemma Copy_out_length :
  forall prefx prm lexp s s',
    Copy_out prefx prm lexp s s'
    -> List.length s = List.length s'.
Proof.
  intros prefx prm lexp s s' H.
  induction H;auto.
  transitivity (List.length σ');auto.
  apply updateG_length in H2.
  assumption.
Qed.



Lemma copy_out_no_rte:
  forall prefx lprm lexp s,
    ~ copy_out prefx lprm lexp s = Run_Time_Error.
Proof.
  intros prefx lprm lexp s.
  functional induction copy_out prefx lprm lexp s;try assumption;try discriminate.
Qed.


Lemma copy_out_correct:
  forall prefx s (prm:list parameter_specification) lexp x,
    copy_out prefx prm lexp s = Normal x <-> Copy_out prefx prm lexp s x.
Proof.
  intros prefx s prm lexp.
  functional induction copy_out prefx prm lexp s;intros;split;simpl in *;intro heq
  ; try (now (inversion heq;subst;clear heq);auto;try now (econstructor;eauto)).
  - apply Copy_out_cons_out with (σ':=s') (v:=v)(id:=parameter_name prm);auto.
    apply IHr.
    assumption.
  - inversion heq;subst.
    + inversion2 fetch.
      apply IHr.
      inversion2 updateG.
    + rewrite e2 in *.
      discriminate.
  - inversion heq;clear heq;subst.
    + inversion2 fetch.
      rewrite H10 in *.
      discriminate e5.
    + rewrite e2 in *.
      discriminate.
  - inversion heq;clear heq;subst.
    + inversion2 fetch.
    + rewrite e2 in *.
      discriminate.
  - inversion heq;subst;try contradiction.
    rewrite e2 in *.
    discriminate.
  - constructor 3;auto.
    apply IHr.
    assumption.
  - inversion heq;subst;try contradiction.
    + rewrite e2 in *.
      discriminate.
    + apply IHr.
      assumption.
  - inversion heq;subst;try contradiction.
    + rewrite H3 in *;contradiction.
    + rewrite H6 in *;contradiction.
Qed.





Lemma eval_decl_store_length:
  forall s sto s' decl,
    eval_decl s sto decl s'
    -> forall st, s' = Normal st
                  -> exists prfx, st = prfx ++ sto.
Proof.
  intros s sto s' decl h.
  induction h;intros st heq;inversion heq;clear heq;subst.
  - exists ((object_name d, Value v)::nil).
    simpl.
    reflexivity.
  - exists ((object_name d, Undefined)::nil);simpl.
    reflexivity.
  - destruct (IHh2 st).
    { reflexivity. }
    destruct (IHh1 s').
    { reflexivity. }
    subst.
    exists (x ++ x0).
    apply app_assoc.
  - exists ((procedure_name pbody, Procedure pbody)::nil);simpl.
    reflexivity.
Qed.



Lemma eval_stmt_store_length:
  forall s s' stm,    
    eval_stmt s stm s'
    -> forall st, s' = Normal st
                  -> stack_eq_length s st.
Proof.
  intros s s' stm H.
  induction H;intros st heq;inversion heq;clear heq; subst;auto.
  - apply updateG_stack_eq_length in H0.
    assumption.
  - apply stack_eq_length_trans with s1.
    + apply IHeval_stmt1.
      reflexivity.
    + apply IHeval_stmt2.
      reflexivity.
  - apply stack_eq_length_refl.
    reflexivity.
  - apply stack_eq_length_trans with s1.
    + apply IHeval_stmt1.
      reflexivity.
    + apply IHeval_stmt2.
      reflexivity.
  - apply stack_eq_length_refl.
    reflexivity.
  -  
    generalize (Cut_until_def _ _ _ _ H1).
    intros hcutin.
    subst.
    specialize (IHeval_stmt ((slocal ++ prefix') :: s') eq_refl).
    inversion IHeval_stmt.
    clear IHeval_stmt.
    subst.
    apply Copy_out_stack_eq_length in H6.
    transitivity (s_forget ++ s').
    rewrite H9.
    reflexivity.
    assumption.
Qed.

Lemma f_eval_decl_correct :
  forall s sto d s',
    f_eval_decl s sto d = Normal s' ->
    eval_decl s sto d (Normal s').
Proof.
  intros s sto d.
  functional induction f_eval_decl s sto d;simpl;intros;try discriminate
  ; try match goal with
        | H: Normal _ = Normal _ |- _ =>
          inversion H;subst;clear H
      end;try now( (econstructor;eauto;try apply f_eval_expr_correct1;auto)).
  - rewrite H in y.
    contradiction.
Qed.

Lemma f_eval_decl_correct2 :
  forall s sto d,
    f_eval_decl s sto d = Run_Time_Error ->
    eval_decl s sto d Run_Time_Error.
Proof.
  intros s sto d.
  functional induction f_eval_decl s sto d;simpl;intros;try discriminate;
  try match goal with
        | H: Normal _ = Run_Time_Error |- _ =>
          inversion H;subst;clear H
      end;try now( (econstructor;eauto);try apply f_eval_expr_correct2;auto).
  
  eapply eval_decl_Seq_err2 with s';auto.
  apply f_eval_decl_correct.
  assumption.
Qed.

Ltac invclear H := inversion H; clear H; subst.

Ltac use_determinism :=
  match goal with
    | H : ?X = ?X |- _ => clear H
    | H: None = ?y, H': ?y = Some ?z |- _ => rewrite H' in H; invclear H
    | H: Some ?z = ?y, H': ?y = None |- _ => rewrite H' in H; invclear H
    | H: Some ?x = ?y, H': ?y = Some ?z |- _ => rewrite H' in H; inversion H;clear H;subst
    | H : eval_expr ?s ?e ?X,
          H': f_eval_expr ?s ?e = ?Y |- _ => rewrite (f_eval_expr_complete s e X H) in H'
    | H:  eval_expr ?s ?e ?X,
          H': eval_expr ?s ?e ?Y |- _ => apply (f_eval_expr_complete s e X) in H
         ;apply (f_eval_expr_complete s e) in H'
    | H : f_eval_expr ?s ?e = ?X,
          H': f_eval_expr ?s ?e = ?Y |- _ => rewrite H in H'; invclear H'
    | H : (Normal ?v) = (Normal ?v') |- _ => invclear H
  end.

Ltac crush := repeat progress use_determinism;try reflexivity;try discriminate.

Lemma f_eval_decl_complete :
  forall d sto s s',
    eval_decl s sto d s' ->
    f_eval_decl s sto d = s'.
Proof.
  intros d sto s.
  functional induction f_eval_decl s sto d;simpl;intros;try discriminate;crush;
  try now (invclear H;crush).
  - invclear H
    ; try match goal with
            | H: eval_decl _ _ dcl1 _ |- _ => rename H into hed1
          end
    ; try match goal with
            | H: eval_decl _ _ dcl2 _ |- _ => rename H into hed2
          end. 
    + apply IHr in hed1.
      rewrite e0 in hed1.
      inversion hed1.
      subst.
      apply IHr0 in hed2.
      assumption.
    + apply IHr in hed1.
      rewrite e0 in hed1.
      inversion hed1.
    + apply IHr in hed1.
      rewrite e0 in hed1.
      inversion hed1.
      subst.
      apply IHr0 in hed2.
      assumption.
  - invclear H
    ; try match goal with
            | H: eval_decl _ _ dcl1 _ |- _ => rename H into hed1
          end
    ; try match goal with
            | H: eval_decl _ _ dcl2 _ |- _ => rename H into hed2
          end.
    + apply IHr in hed1.
      rewrite hed1 in y.
      contradiction.
    + apply IHr in hed1.
      assumption.
    + apply IHr in hed1.
      rewrite hed1 in y.
      contradiction.
Qed.


(** ** Bisimulation between f_eval_stmt and eval_stmt for statement semantics *)


Ltac rm_f_eval_expr :=
  match goal with 
    | [ h: f_eval_expr ?s ?b = Run_Time_Error |- _ ] => 
      specialize (f_eval_expr_correct2 _ _ h); intros hz1
    | [ h: f_eval_expr ?s ?b = Normal ?v |- _ ] => 
      specialize (f_eval_expr_correct1 _ _ _ h); intros hz1   
  end; auto.



(** a help lemma to prove the theorem: 'f_eval_stmt_complete' *)
Lemma f_eval_stmt_correct1 : forall k s p s',
        f_eval_stmt k s p = Normal s' ->
          eval_stmt s p (Normal s').
Proof.
    intros k s p.
    functional induction (f_eval_stmt k s p);
    intros; try inversion H; subst.
  - (* S_Assignment *)
    econstructor.
    rm_f_eval_expr.
    apply hz1.
    assumption.
  - (* S_Sequence *)
    specialize (IHr _ e1).
    specialize (IHr0 _ H).
    econstructor.
    apply IHr.
    apply_inv.
  - (* S_If_True *)
    specialize (IHr _ H).
    econstructor.
    rm_f_eval_expr. 
    apply_inv.
  - (* S_If_False *)
    eapply eval_S_If_False.
    rm_f_eval_expr.
  - (* S_While_Loop_True *)
    specialize (IHr _ e2).
    specialize (IHr0 _ H).
    econstructor.
    rm_f_eval_expr.
    apply IHr. 
    apply_inv.
  - (* S_While_Loop_False *)
    eapply eval_S_While_Loop_False.
    rm_f_eval_expr.
  - (* S_ProcCall *)
    clear H.
    (* cleaning by going to inductive defs *)
    apply split1_correct in e6.
    destruct e6 as [hsplit1 hsplit2].
    rewrite H1.
    subst.
    apply f_eval_decl_correct in e4.    
    apply IHr in e5.
    apply copy_in_correct in e2.
    apply copy_out_correct in H1.
    (* ******* *)
    eapply eval_S_Proc with (s':=s') (prefix':=prefx')(prefix:=prefx)(slocal:=slocal);eauto.
    + apply cut_until_complete1.
      assumption.
    + eapply eval_decl_store_length with (st:=s2) in e4;auto.
      destruct e4 as [slocal' ?]. subst.
      apply eval_stmt_store_length with (st:=((slocal ++ prefx') :: s')) in e5;auto.
      inversion e5. clear e5. subst.
      rewrite <- H5 in hsplit1.
      setoid_rewrite app_length in H5.
      setoid_rewrite app_length in hsplit1.
    omega.
Qed.


Ltac rm_f_eval_stmt :=
    match goal with 
    | [ h: f_eval_stmt ?k ?s ?c = Normal ?s1 |- _ ] => 
        specialize (f_eval_stmt_correct1 _ _ _ _ h); intros hz1
    end; auto.

(** a help lemma to prove the theorem: 'f_eval_stmt_complete' *)
Lemma f_eval_stmt_correct2 : forall k s p,
        f_eval_stmt k s p = Run_Time_Error ->
          eval_stmt s p Run_Time_Error.
Proof.
    intros k s p.
    functional induction (f_eval_stmt k s p);
      intros H ; try inversion H;  subst.
  - (* S_Assignment *)
    econstructor.
    rm_f_eval_expr.
  - (* S_Sequence*)
    specialize (IHr0 H).
    econstructor.
    rm_f_eval_stmt.
    apply hz1.
    apply_inv.
  - specialize (IHr e1).
    econstructor.
    assumption.    
  - (* C_If *)
    specialize (IHr H).
    econstructor.
    rm_f_eval_expr.
    apply_inv.
  - econstructor.
    specialize (f_eval_expr_correct2 _ _ e1); intros hz1. 
    assumption.
  - (* S_While_Loop *)
    specialize (IHr0 H).
    econstructor.
    rm_f_eval_expr.
    rm_f_eval_stmt.
    apply hz1.
    apply_inv.
  - constructor 9.
    rm_f_eval_expr.
    specialize (IHr e2); assumption.    
  - econstructor.
    rm_f_eval_expr.
  - elim (copy_out_no_rte _ _ _ _ H1).
  - apply eval_S_Proc_rtebody with 
    (prefix:=prefx)
      (s2:=s2)
      (s:=s_called)
      (s_forget:=s_forget)
      (pb:=pb);auto. 
    + apply copy_in_correct.
      assumption.
    + apply cut_until_complete1.
      assumption.
    + apply f_eval_decl_correct.
      assumption.
  - apply eval_S_Proc_rtedecl
    with (prefix:=prefx) (pb:=pb) (s_forget:=s_forget) (s:=s_called)
    ;eauto.
    + apply copy_in_correct.
      assumption.
    + apply cut_until_complete1.
      assumption.
    + eapply f_eval_decl_correct2.
      assumption.
  - eapply eval_S_Proc_rteargs with pb;auto.
    apply copy_in_correct2.
    assumption.
Qed.
    
    

Ltac rm_f_eval :=
    match goal with 
    | [ h: f_eval_expr ?s ?b = Run_Time_Error |- _ ] => specialize (f_eval_expr_correct2 _ _ h); intros hz1
    | [ h: f_eval_expr ?s ?b = Normal ?v |- _ ] => specialize (f_eval_expr_correct1 _ _ _ h); intros hz1   
    | [ h: f_eval_stmt ?k ?s ?c = Run_Time_Error |- _ ] => specialize (f_eval_stmt_correct2 _ _ _ h); intros hz1
    | [ h: f_eval_stmt ?k ?s ?c = Normal ?s1 |- _ ] => specialize (f_eval_stmt_correct1 _ _ _ _ h); intros hz1
    end; auto.

(** *** f_eval_stmt_correct *)
(** 
   for any statement c starting from initial state s, if it returns 
   a normal state s' or terminates in a run time error within k steps
   with respect to the functional semantics 'f_eval_stmt', then the 
   relation between s, c and the resulting state should also be 
   satisfied with respect to the relational semantics 'eval_stmt';
*)
Theorem f_eval_stmt_correct : forall k s c s',
        (f_eval_stmt k s c = Normal s' ->
          eval_stmt s c (Normal s')) /\ 
        (f_eval_stmt k s c = Run_Time_Error ->
          eval_stmt s c Run_Time_Error).
Proof.
    intros.
    split; intros;
    rm_f_eval.
Qed.

(** *** f_eval_stmt_complete *)
(** 
   the reverse direction is also satisfied: for any statement c, 
   whenever it's executed starting from initial state s and return 
   a new state s' with regard to the relational semantics 'eval_stmt', 
   then there should exist a constant k that statement c starting from 
   s will terminate in state s' within k steps with respect to the 
   functional semantics 'f_eval_stmt';
*)

Ltac apply_rewrite := 
    match goal with
    | h: eval_expr ?s ?e ?s' |- _ => 
        rewrite (f_eval_expr_complete _ _ _ h)
    | h: update _ _ _ = _ |- _ => rewrite h
    | h: updateG _ _ _ = _ |- _ => rewrite h
    | h: f_eval_stmt _ _ _ = _ |- _ => rewrite h
    | h: f_eval_expr _ _ = _ |- _ => rewrite h
    | h: fetch _ _ = _ |- _ => rewrite h
    | h: fetchG _ _ = _ |- _ => rewrite h
    | h: copy_in _ _ _ = _ |- _ => rewrite h
    | h: Copy_in _ _ _ Run_Time_Error |- _ => rewrite <- copy_in_correct2 in h;rewrite h
    | h: Copy_in _ _ _ (Normal _) |- _ => rewrite <- copy_in_correct in h;rewrite h
    | h: cut_until _ _ = Some(_, _) |- _ => rewrite h
    | h: cut_until _ _ = None |- _ => rewrite h
    | h: Cut_until _ _ _ _ |- _ => apply cut_until_correct in h;rewrite h
    end; auto.

Theorem f_eval_stmt_complete : forall s c s',
        eval_stmt s c s' -> (* s' is either a normal state or a run time error *)
            exists k, f_eval_stmt k s c = s'.
Proof. 
  intros s c s' H;
  induction H;
  try match goal with
  [ h: eval_expr ?s ?e Run_Time_Error |- exists k, _ = Run_Time_Error] => 
          exists 1%nat; simpl;
          rewrite (f_eval_expr_complete _ _ _ h);
          reflexivity
  end.
  (* 1. S_Assignment *)
  - exists 1%nat; simpl.
    repeat apply_rewrite.
  (* 2. S_Sequence *)
  - destrIH.
    exists (S k); simpl.
    apply_rewrite.
  - destrIH.
    exists (S (k0+k)); simpl.
    kgreater.
    specialize (eval_stmt_state _ _ _ H0); intros hz1.
    destruct hz1 as [hz2 | hz2]; try rm_exists; subst;
    kgreater.
  (* 3. S_If *)
  - destrIH.
    exists (S k); simpl.
    apply_rewrite.
  - exists 1%nat; simpl.
    apply_rewrite.
  (* 4. S_While_Loop *)
  - destrIH.
    exists (S k); simpl.
    repeat apply_rewrite.
  - destrIH.
    exists (S (k0+k)); simpl.
    apply_rewrite.
    kgreater.
    specialize (eval_stmt_state _ _ _ H1); intros hz1.
    destruct hz1 as [hz2 | hz2]; try rm_exists; subst;
    kgreater.
  - exists 1%nat; simpl.
    apply_rewrite.
  - exists 1%nat; simpl.
    repeat progress apply_rewrite.
  - exists 1%nat; simpl.
    subst.
    repeat apply_rewrite.
    apply f_eval_decl_complete in H2.
    rewrite H2.
    reflexivity.
  - destruct IHeval_stmt as [k IH].
    exists (S k).
    simpl.
    repeat apply_rewrite.
    apply f_eval_decl_complete in H2.
    rewrite H2.
    apply_rewrite.
  - destruct IHeval_stmt as [k IH].
    exists (S k).
    simpl.
    subst.
    repeat apply_rewrite.
    apply f_eval_decl_complete in H2.
    rewrite H2.
    repeat apply_rewrite.
    repeat setoid_rewrite app_length.
    rewrite H5.
    assert (heq:Datatypes.length slocal + Datatypes.length prefix' -
        Datatypes.length prefix' = Datatypes.length slocal) by omega.
    rewrite heq.
    rewrite split1_complete with (l2:=prefix') (l1:=slocal).
    + apply copy_out_correct.
      assumption.
    + reflexivity.
    + reflexivity.
Qed.

(**********************************************************************)
(**********************************************************************)

(** * Subprogram Semantics *)

(** In the current SPARK subset, there is no procedure call, 
    so right now we only define the semantics for the main procedure.
    And it can be used to test the tool chain from SPARK source code 
    to Coq evaluation; Later, we will add the procedure call and 
    modify the following procedure semantics;
*)

(** all declared variables in the same procedure should have unique 
    names; 
*)

(** relational (eval_decl) and functional (f_eval_decl) semantics for 
    variable declaration;
*)

(** for any initial state s, after executing the declaration d, 
    it either returns a normal state s' or a run time error;
    (for any variable declaration, if its initialization expression 
     fails the run time checks, for example division by zero or overflow, 
     then it returns an exception)
*)

Lemma eval_decl_state : forall s sto d s',
        eval_decl s sto d s' -> (* s' is either a normal state or a run time error *)
            (exists t, s' = Normal t) \/ s' = Run_Time_Error.
Proof.
    intros s sto d s' h.
    induction h;
    try match goal with
    | [ |- (exists t, Normal ?t1 = Normal t) \/ _ ] => left; exists t1; reflexivity
    | [ |- context [ _ \/ ?A = ?A ] ] => right; reflexivity
    end; auto.
Qed.


(** f_eval_decl completeness and correctness proofs *)

(** bisimulation proof between f_eval_decl and eval_decl: 
    - f_eval_decl_correct
    - f_eval_decl_complete
*)

Lemma f_eval_decl_correct_: forall d s sto s',
    (f_eval_decl s sto d = (Normal s') -> eval_decl s sto d (Normal s')) /\
    (f_eval_decl s sto d = Run_Time_Error -> eval_decl s sto d Run_Time_Error).
Proof.
    intros d s sto.
    intros s'.
    split;intro h.
    - apply f_eval_decl_correct.
      assumption.
    - apply f_eval_decl_correct2.
      assumption.
Qed.


(* = = = = = = Subprogram Body = = = = = =  *)
(** relational and functional semantics for procedure body; *)
(* Is this still needed for global procedures? probably not. *)
(* main procedure has no argument, so we give the nil store as
   parameter store *)
Inductive eval_proc: stack -> procedure_body -> Return stack -> Prop :=
    | eval_Proc_E: forall f s,
        eval_decl s nil (procedure_declarative_part f) Run_Time_Error ->
        eval_proc s f Run_Time_Error
    | eval_Proc: forall f s1 s2 s3,
        eval_decl s1 nil (procedure_declarative_part f) (Normal s2) ->
        eval_stmt (s2::s1) (procedure_statements f) s3 ->
        eval_proc s1 f s3.

Function f_eval_proc k (s: stack) (f: procedure_body): Return stack :=
    match (f_eval_decl s nil (procedure_declarative_part f)) with
    | Normal s' => f_eval_stmt k (s'::s) (procedure_statements f)
    | Run_Time_Error => Run_Time_Error
    | Abnormal => Abnormal
    | Unterminated => Unterminated
    end.


(** ** Main Procedure Evaluation Without Parameters *)

(** relational and functional semantics for main procedure; *)

Inductive eval_subprogram: stack -> subprogram -> Return stack -> Prop :=
    | eval_Procedure: forall s s' ast_num f,
        eval_proc s f s' ->
        eval_subprogram s (Global_Procedure ast_num f) s'.

Function f_eval_subprogram k (s: stack) (f: subprogram): Return stack := 
    match f with 
    | Global_Procedure ast_num f' => f_eval_proc k s f'
    end.

(** ** Bisimulation Between Relational And Functional Semantics For Main Procedure *)

(** *** f_eval_subprogram_correct *)
Theorem f_eval_subprogram_correct: forall k s f s',
    (f_eval_subprogram k s f = Normal s' -> 
        eval_subprogram s f (Normal s')) /\
    (f_eval_subprogram k s f = Run_Time_Error -> 
        eval_subprogram s f Run_Time_Error).
Proof.
    intros; 
    split; intros;
    destruct f;
    simpl in H;
    constructor;
    unfold f_eval_proc in H;
    remember (f_eval_decl s nil (procedure_declarative_part p)) as x;
    symmetry in Heqx.
  - (* normal state *)
    destruct x; inversion H; subst.
    econstructor.
    + apply f_eval_decl_correct in Heqx.
       apply Heqx.
    + apply f_eval_stmt_correct in H.
       rewrite H1; auto.
  - (* run time error *)
    destruct x; inversion H; subst.
    + econstructor.
       * apply f_eval_decl_correct in Heqx.
         apply Heqx.
       * rewrite H.
         apply f_eval_stmt_correct in H; auto.
    + econstructor.
      apply f_eval_decl_correct2 in Heqx; auto.
Qed.

(** *** f_eval_subprogram_complete *)
Theorem f_eval_subprogram_complete: forall s f s',
    eval_subprogram s f s' ->
    exists k, f_eval_subprogram k s f = s'.
Proof.
    intros s f s' h.
    unfold f_eval_subprogram.
    unfold f_eval_proc.
    inversion h; subst.
    inversion H; subst.
  - apply f_eval_decl_complete in H0.
    rewrite H0. 
    exists 0; auto.
  - apply f_eval_decl_complete in H0.
    rewrite H0.
    apply f_eval_stmt_complete in H1.
    auto.
Qed.

(** * Replaying examples using the correctness of functional semantics *)
Module ExampleProcedures2.
(* EXAMPLE 1, v102 is a variable in the scope.
------------------------
procedure P2 () is
  V4 : TYPE5 := 34;
begin
  V102 := 56;
end 
-----------------------
*)
Definition proc1:procedure_body := (mkprocedure_body
           1 2 nil nil
             (D_Object_declaration
                {|
                  declaration_astnum := 3;
                  object_name := 4;
                  object_nominal_subtype :=  5;
                  initialization_expression := Some (E_Literal 6 (Integer_Literal(34)))
                |}
             )
             (S_Assignment 12 102 (E_Literal 8 (Integer_Literal(56))))).

Definition s1:store := (101,Procedure proc1) :: (102, Value (Int(77))) :: nil.

Definition s2:store := (101,Procedure proc1) :: (102, Value (Int(56)))  :: nil.

Eval vm_compute in f_eval_stmt 200 (s1::nil) (S_ProcCall 13 101 nil).

Lemma essai: eval_stmt (s1::nil) (S_ProcCall 13 101 nil) (Normal (s2::nil)).
Proof.
  apply f_eval_stmt_correct1 with (k:=2).
  compute.
  reflexivity.
Qed.



(* v102 is a variable in the scope.
procedure P2 () is
  V4 : TYPE5 := 34;
  V5 : TYPE5 := 37;
begin
  V5 := V4 + V5;
  V102 := V5*2;
end 
*)
Definition proc2:procedure_body := (mkprocedure_body
           1 2 nil nil
             (D_Sequence
                (D_Object_declaration
                   {|
                     declaration_astnum := 3;
                     object_name := 4;
                     object_nominal_subtype :=  5;
                     initialization_expression := Some (E_Literal 6 (Integer_Literal(34)))
                   |}
                )
                (D_Object_declaration
                   {|
                     declaration_astnum := 4;
                     object_name := 5;
                     object_nominal_subtype :=  5;
                     initialization_expression := Some (E_Literal 6 (Integer_Literal(37)))
                   |}
                )
             )
             (S_Sequence 13
                (S_Assignment 14 5
                              (E_Binary_Operation 9 Plus
                                                  (E_Identifier 10 5)
                                                  (E_Identifier 10 4)))
                (S_Assignment
                   12
                   102
                   (E_Binary_Operation 9 Multiply
                                       (E_Identifier 10 5)
                                       (E_Literal 8 (Integer_Literal(2))))))).

Definition s3:store := (101,Procedure proc2) :: (102, Value (Int(77))) :: nil.

Definition s4:store := (101,Procedure proc2) :: (102, Value (Int(142)))  :: nil.


Lemma essai2: eval_stmt (s3::nil) (S_ProcCall 13 101 nil) (Normal (s4::nil)).
Proof.
  apply f_eval_stmt_correct1 with (k:=200).
  vm_compute.
  reflexivity.
Qed.


End ExampleProcedures2.
(* END EXAMPLE *)  

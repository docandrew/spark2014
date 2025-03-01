Aspects or Pragmas Specific to GNATprove
========================================

This appendix lists all the aspects or pragmas specific to |GNATprove|,
in particular all the uses of aspect or pragma ``Annotate`` for
|GNATprove|.  Aspect or pragma ``Annotate`` can also be used to control other
AdaCore tools. The uses of such annotations are explained in the User's guide
of each tool.

Annotations in |GNATprove| are useful in two cases:

1. for justifying check messages using :ref:`Direct Justification with Pragma
   Annotate`, typically using a pragma rather than an aspect, as the
   justification is generally associated to a statement or declaration.

2. for influencing the generation of proof obligations, typically using an
   aspect rather than a pragma, as the annotation is generally associated to an
   entity in that case. Some of these uses can be seen in :ref:`SPARK
   Libraries` for example. Some of these annotations introduce additional
   assumptions which are not verified by the |GNATprove| tool, and thus should
   be used with care.

When the annotation is associated to an entity, both the pragma and aspect form
can be used and are equivalent, for example on a subprogram:

.. code-block:: ada

    function Func (X : T) return T
      with Annotate => (GNATprove, <annotation name>);

or

.. code-block:: ada

    function Func (X : T) return T;
    pragma Annotate (GNATprove, <annotation name>, Func);

In the following, we use the aspect form whenever possible.

.. index:: Annotate; False_Positive
           Annotate; Intentional

Using Annotations to Justify Check Messages
-------------------------------------------

You can use annotations of the form

.. code-block:: ada

    pragma Annotate (GNATprove, False_Positive,
                     "message to be justified", "reason");

to justify an unproved check message that cannot be proved by other means. See
the section :ref:`Direct Justification with Pragma Annotate` for more details
about this use of pragma ``Annotate``.

.. index:: Annotate; Might_Not_Return

Using Annotations to Specify Possibly Nonreturning Procedures
-------------------------------------------------------------

You can use annotations of the form

.. code-block:: ada

    procedure Proc
      with Annotate => (GNATprove, Might_Not_Return);

to specify that a procedure might not return. See the section
:ref:`Nonreturning Procedures` for more details about this use of
annotations.

.. index:: Annotate; Terminating

Using Annotations to Request Proof of Termination
-------------------------------------------------

By default, |GNATprove| does not prove termination of subprograms. You can
instruct it to do so using annotations of the form:

.. code-block:: ada

   procedure Proc
     with Annotate => (GNATprove, Terminating);

See the section :ref:`Subprogram Termination` about details of this use of
annotations.

.. index:: Annotate; No_Wrap_Around

Using Annotations to Request Overflow Checking on Modular Types
---------------------------------------------------------------

The standard semantics of arithmetic on modular types is that operations wrap
around, hence |GNATprove| issues no overflow checks on such operations.
You can instruct it to issue such checks (hence detecting possible wrap-around)
using annotations of the form:

.. code-block:: ada

   type T is mod 2**32
     with Annotate => (GNATprove, No_Wrap_Around);

or on a derived type:

.. code-block:: ada

   type T is new U
     with Annotate => (GNATprove, No_Wrap_Around);

This annotation is inherited by derived types. It must be specified on a type
declaration (and cannot be specified on a subtype declaration). All four binary
arithmetic operations + - * \*\* are checked for possible overflows. Division
cannot lead to overflow. Unary negation is checked for possible non-nullity of
its argument, which leads to overflow. The predecessor attribute ``'Pred`` and
successor attribute ``'Succ`` are also checked for possible overflows.

.. index:: Annotate; Iterable

Customize Quantification over Types with the Iterable Aspect
------------------------------------------------------------

In |SPARK|, it is possible to allow quantification over any container type
using the ``Iterable`` aspect.
This aspect provides the primitives of a container type that will be used to
iterate over its content. For example, if we write:

.. code-block:: ada

   type Container is private with
     Iterable => (First       => First,
                  Next        => Next,
                  Has_Element => Has_Element);

where

.. code-block:: ada

   function First (S : Set) return Cursor;
   function Has_Element (S : Set; C : Cursor) return Boolean;
   function Next (S : Set; C : Cursor) return Cursor;

then quantification over containers can be done using the type ``Cursor``. For
example, we could state:

.. code-block:: ada

   (for all C in S => P (Element (S, C)))

to say that ``S`` only contains elements for which a property ``P`` holds. For
execution, this expression is translated as a loop using the provided ``First``,
``Has_Element``, and ``Next`` primitives. For proof, it is translated as a logic
quantification over every element of type ``Cursor``. To restrict the property
to cursors that are actually valid in the container, the provided function
``Has_Element`` is used. For example, the property stated above becomes:

.. code-block:: ada

   (for all C : Cursor => (if Has_Element (S, C) then P (Element (S, C))))

Like for the standard Ada iteration mechanism, it is possible to allow
quantification directly over the elements of the container by providing in
addition an ``Element`` primitive to the ``Iterable`` aspect. For example, if
we write:

.. code-block:: ada

   type Container is private with
     Iterable => (First       => First,
                  Next        => Next,
                  Has_Element => Has_Element
                  Element     => Element);

where

.. code-block:: ada

   function Element (S : Set; C : Cursor) return Element_Type;

then quantification over containers can be done directly on its elements. For
example, we could rewrite the above property into:

.. code-block:: ada

   (for all E of S => P (E))

For execution, quantification over elements of a container is translated as a
loop over its cursors. In the same way, for proof, quantification over elements
of a container is no more than syntactic sugar for quantification over its
cursors. For example, the above property is translated using quantification
over cursors :

.. code-block:: ada

   (for all C : Cursor => (if Has_Element (S, C) then P (Element (S, C))))

Depending on the application, this translation may be too low-level and
introduce an unnecessary burden on the automatic provers. As an example, let
us consider a package for functional sets:

.. code-block:: ada

  package Sets with SPARK_Mode is

    type Cursor is private;
    type Set (<>) is private with
      Iterable => (First       => First,
                   Next        => Next,
                   Has_Element => Has_Element,
                   Element     => Element);

    function Mem (S : Set; E : Element_Type) return Boolean with
      Post => Mem'Result = (for some F of S => F = E);

    function Intersection (S1, S2 : Set) return Set with
      Post => (for all E of Intersection'Result => Mem (S1, E) and Mem (S2, E))
        and (for all E of S1 =>
	         (if Mem (S2, E) then Mem (Intersection'Result, E)));

Sets contain elements of type ``Element_Type``. The most basic operation on sets
is membership test, here provided by the ``Mem`` subprogram. Every other
operation, such as intersection here, is then specified in terms of members.
Iteration primitives ``First``, ``Next``, ``Has_Element``, and ``Element``, that
take elements of a private type ``Cursor`` as an argument, are only provided for
the sake of quantification.

Following the scheme described previously, the postcondition of ``Intersection``
is translated for proof as:

.. code-block:: ada

  (for all C : Cursor =>
      (if Has_Element (Intersection'Result, C) then
             Mem (S1, Element (Intersection'Result, C))
         and Mem (S2, Element (Intersection'Result, C))))
  and
  (for all C1 : Cursor =>
      (if Has_Element (S1, C1) then
             (if Mem (S2, Element (S1, C1)) then
                   Mem (Intersection'Result, Element (S1, C1)))))

Using the postcondition of ``Mem``, this can be refined further into:

.. code-block:: ada

  (for all C : Cursor =>
      (if Has_Element (Intersection'Result, C) then
             (for some C1 : Cursor =>
                 Has_Element (S1, C1) and Element (Intersection'Result, C) = Element (S1, C1))
         and (for some C2 : Cursor =>
                 Has_Element (S2, C2) and Element (Intersection'Result, C) = Element (S2, C2))))
  and
  (for all C1 : Cursor =>
      (if Has_Element (S1, C1) then
             (if (for some C2 : Cursor =>
                 Has_Element (S2, C2) and Element (S1, C1) = Element (S2, C2)))
      then (for some C : Cursor => Has_Element (Intersection'Result, C)
               and Element (Intersection'Result, C) = Element (S1, C1))))

.. index:: Annotate; Iterable_For_Proof

Though perfectly valid, this translation may produce complicated proofs,
especially when verifying complex properties over sets. The |GNATprove|
annotation ``Iterable_For_Proof`` can be used to change the way ``for ... of``
quantification is translated. More precisely, it allows to provide |GNATprove|
with a `Contains` function, that will be used for quantification. For example,
on our sets, we could write:

.. code-block:: ada

  function Mem (S : Set; E : Element_Type) return Boolean;
  pragma Annotate (GNATprove, Iterable_For_Proof, "Contains", Mem);

With this annotation, the postcondition of ``Intersection`` is translated in a
simpler way, using logic quantification directly over elements:

.. code-block:: ada

  (for all E : Element_Type =>
       (if Mem (Intersection'Result, E) then Mem (S1, E) and Mem (S2, E)))
  and (for all E : Element_Type =>
       (if Mem (S1, E) then
              (if Mem (S2, E) then Mem (Intersection'Result, E))))

Note that care should be taken to provide an appropriate function contains,
which returns true if and only if the element ``E`` is present in ``S``. This
assumption will not be verified by |GNATprove|.

The annotation ``Iterable_For_Proof`` can also be used in another case.
Operations over complex data structures are sometimes specified using operations
over a simpler model type. In this case, it may be more appropriate to translate
``for ... of`` quantification as quantification over the model's cursors. As an
example, let us consider a package of linked lists that is specified using a
sequence that allows accessing the element stored at each position:

.. code-block:: ada

  package Lists with SPARK_Mode is

   type Sequence is private with
     Ghost,
     Iterable => (...,
                  Element     => Get);
   function Length (M : Sequence) return Natural with Ghost;
   function Get (M : Sequence; P : Positive) return Element_Type with
     Ghost,
     Pre => P <= Length (M);

   type Cursor is private;
   type List is private with
     Iterable => (...,
                  Element     => Element);

   function Position (L : List; C : Cursor) return Positive with Ghost;
   function Model (L : List) return Sequence with
     Ghost,
     Post => (for all I in 1 .. Length (Model'Result) =>
                  (for some C in L => Position (L, C) = I));

   function Element (L : List; C : Cursor) return Element_Type with
     Pre  => Has_Element (L, C),
     Post => Element'Result = Get (Model (L), Position (L, C));

   function Has_Element (L : List; C : Cursor) return Boolean with
     Post => Has_Element'Result = (Position (L, C) in 1 .. Length (Model (L)));

   procedure Append (L : in out List; E : Element_Type) with
     Post => length (Model (L)) = Length (Model (L))'Old + 1
     and Get (Model (L), Length (Model (L))) = E
     and (for all I in 1 .. Length (Model (L))'Old =>
            Get (Model (L), I) = Get (Model (L'Old), I));

   function Init (N : Natural; E : Element_Type) return List with
     Post => length (Model (Init'Result)) = N
       and (for all F of Init'Result => F = E);

Elements of lists can only be accessed through cursors. To specify easily the
effects of position-based operations such as ``Append``, we introduce a ghost
type ``Sequence``, that is used to represent logically the content of the linked
list in specifications.
The sequence associated to a list can be constructed using the ``Model``
function. Following the usual translation scheme for quantified expressions, the
last line of the postcondition of ``Init`` is translated for proof as:

.. code-block:: ada

  (for all C : Cursor =>
      (if Has_Element (Init'Result, C) then Element (Init'Result, C) = E));

Using the definition of ``Element`` and ``Has_Element``, it can then be refined
further into:

.. code-block:: ada

  (for all C : Cursor =>
      (if Position (Init'Result, C) in 1 .. Length (Model (Init'Result))
       then Get (Model (Init'Result), Position (Init'Result, C)) = E));

To be able to link this property with other properties specified directly on
models, like the postcondition of ``Append``, it needs to be lifted to iterate
over positions instead of cursors. This can be done using the postcondition of
``Model`` that states that there is a valid cursor in ``L`` for each position of
its model. This lifting requires a lot of quantifier reasoning from the prover,
thus making proofs more difficult.

The |GNATprove| ``Iterable_For_Proof`` annotation can be used to provide
|GNATprove| with a `Model` function, that will be to translate quantification on
complex containers toward quantification on their model. For example, on our
lists, we could write:

.. code-block:: ada

   function Model (L : List) return Sequence;
   pragma Annotate (GNATprove, Iterable_For_Proof, "Model", Entity => Model);

With this annotation, the postcondition of ``Init`` is translated directly as a
quantification on the elements of the result's model:

.. code-block:: ada

  (for all I : Positive =>
     (if I in 1 .. Length (Model (Init'Result)) then
        Get (Model (Init'Result), I) = E));

Like with the previous annotation, care should be taken to define the model
function such that it always return a model containing exactly the same elements
as ``L``.

.. index:: Annotate; Inline_For_Proof

Inlining Functions for Proof
----------------------------

Contracts for functions are generally translated by |GNATprove| as axioms on
otherwise undefined functions. As an example, consider the following function:

.. code-block:: ada

    function Increment (X : Integer) return Integer with
      Post => Increment'Result >= X;

It will be translated by GNATprove as follows:

.. code-block:: ada

    function Increment (X : Integer) return Integer;

    axiom : (for all X : Integer. Increment (X) >= X);

For internal reasons due to ordering issues, expression functions are also
defined using axioms. For example:

.. code-block:: ada

    function Is_Positive (X : Integer) return Boolean is (X > 0);

will be translated exactly as if its definition was given through a
postcondition, namely:

.. code-block:: ada

    function Is_Positive (X : Integer) return Boolean;

    axiom : (for all X : Integer. Is_Positive (X) = (X > 0));

This encoding may sometimes cause difficulties to the underlying solvers,
especially for quantifier instantiation heuristics. This can cause strange
behaviors, where an assertion is proven when some calls to expression
functions are manually inlined but not without this inlining.

If such a case occurs, it is sometimes possible to instruct the tool to inline
the definition of expression functions using pragma ``Annotate``
``Inline_For_Proof``. When such a pragma is provided for an expression
function, a direct definition will be used for the function instead of an
axiom:

.. code-block:: ada

    function Is_Positive (X : Integer) return Boolean is (X > 0);
    pragma Annotate (GNATprove, Inline_For_Proof, Is_Positive);

The same pragma will also allow to inline a regular function, if its
postcondition is simply an equality between its result and an expression:

.. code-block:: ada

    function Is_Positive (X : Integer) return Boolean with
      Post => Is_Positive'Result = (X > 0);
    pragma Annotate (GNATprove, Inline_For_Proof, Is_Positive);

In this case, |GNATprove| will introduce a check when verifying the body of
``Is_Positive`` to make sure that the inline annotation is correct, namely, that
``Is_Positive (X)`` and ``X > 0`` always yield the same result. This check
may not be redundant with the verification of the postcondition of
``Is_Positive`` if the ``=`` symbol on booleans has been overridden.

Note that, since the translation through axioms is necessary for ordering
issues, this annotation can sometimes lead to a crash in GNATprove. It is the
case for example when the definition of the function uses quantification over a
container using the ``Iterable`` aspect.

.. index:: Annotate; Pledge

.. _Referring to a value at the end of a borrow:

Referring to a Value at the End of a Local Borrow
-------------------------------------------------

Local borrowers are objects of an anonymous access-to-variable type. At their
declaration, the ownership of (a part of) an existing data-structure is
temporarily transferred to the new object. The borrowed data-structure
will regain ownership afterward.

During the lifetime of the borrower, the borrowed object can be modified
indirectly through the borrower. It is forbidden to modify or even read the
borrowed object during the borrow. It can be problematic in some cases, for
example if a borrower is modified inside a loop, as GNATprove will need
information supplied in a loop invariant to know how the borrowed object and
the borrower are related in the loop and after it.

In assertions, we are still allowed to
express properties over a borrowed object using a `pledge`. The notion of
pledges was introduced by researchers from ETH Zurich to verify Rust programs
(see https://2019.splashcon.org/details/splash-2019-oopsla/31/Leveraging-Rust-Types-for-Modular-Specification-and-Verification).
Conceptually, a pledge is a property involving a borrower and/or the expression
it borrows which is known to hold at the end of the borrow, no matter
the modifications that may be done to the borrower. In |SPARK|, it is possible
to refer to the value of a local borrower or a borrowed expression at the
end of the borrow inside a regular assertion or contract, or as a parameter of
a call to a lemma function, using a function
annotated with the ``At_End_Borrow Annotate`` pragma:

.. code-block:: ada

   function At_End_Borrow (E : access constant T) return access constant T is
     (E)
   with Ghost,
     Annotate => (GNATprove, At_End_Borrow);

Note that the name of the function could be something other than
``At_End_Borrow``, but the annotation must use the string ``At_End_Borrow``.
|GNATprove| will check that a function associated with the ``At_End_Borrow``
annotation is a ghost expression function which takes a single parameter of an
access-to-constant type and returns it.

When |GNATprove| encounters a call to such a function, it checks that the
actual parameter of the call is rooted either at a local borrower or at an
expression which is borrowed in the current scope. It will not interpret it as
the current value of the expression, but rather as an imprecise value
representing the value that the expression could have at the end of the borrow.
As |GNATprove| does not do any forward look-ahead, nothing will be known about
the value of a local borrower at the end of the borrow, but the tool will still
be aware of the relation between this final value and the final value of the
expression it borrows.
As an example, let us consider a recursive type of doubly-linked lists:

.. code-block:: ada

    type List;
    type List_Acc is access List;
    type List is record
       Val  : Integer;
       Next : List_Acc;
    end record;

Using this type, let us construct a list ``X`` which stored the numbers form
1 to 5:

.. code-block:: ada

    X := new List'(1, null);
    X.Next := new List'(2, null);
    X.Next.Next := new List'(3, null);
    X.Next.Next.Next := new List'(4, null);
    X.Next.Next.Next.Next := new List'(5, null);

We can borrow the structure designated by ``X`` in a local borrower ``Y``:

.. code-block:: ada

   declare
      Y : access List := X;
   begin
     ...
   end;

While in the scope of ``Y``, the ownership of the list designated by ``X`` is
transferred to ``Y``, so that it is not allowed to access it from ``X``
anymore. After the end of the declare block, ownership is restored to ``X``,
which can again be accessed or modified directly.

Let us now define a function that can be used to relate the values
designated by ``X`` and ``Y`` at the end of the borrow:

.. code-block:: ada

   function At_End_Borrow (L : access constant List) return access constant List is
     (L)
   with Ghost,
     Annotate => (GNATprove, At_End_Borrow);

We can use this function to give properties that are known to hold during the
scope of ``Y``. Since ``Y`` and ``X`` designate the same value, we can
state in a pledge that the ``Val`` and ``Next`` components of ``X`` and ``Y``
always match:

.. code-block:: ada

      pragma Assert (At_End_Borrow (X).Val = At_End_Borrow (Y).Val);
      pragma Assert (At_End_Borrow (X).Next = At_End_Borrow (Y).Next);

However, even though at the beginning of the declare block, the first value of
``X`` is 1, it is not correct to assert that it will remain so inside a pledge:

.. code-block:: ada

      pragma Assert (Y.Val = 1);                 --  proved
      pragma Assert (At_End_Borrow (X).Val = 1); --  incorrect

Indeed, ``Y`` could be modified later so that ``X.Val`` is not 1 anymore:

.. code-block:: ada

   declare
      Y : access List := X;
   begin
      Y.Val := 2;
   end;
   pragma Assert (X.Val = 2);

Note that the pledge above is invalid even if ``Y.Val`` is `not` modified in the
following statements. A pledge is a contract about what
`is known to necessarily hold` in the
scope of ``Y``, not what will happen in practice. The analysis performed by
|GNATprove| remains a forward analysis, which is not impacted by
statements occurring after the current one.

Let us now consider a case where ``X`` is not borrowed completely. In the
declaration of ``Y``, we can decide to borrow only the last three elements of
the list:

.. code-block:: ada

   declare
      Y : access List := X.Next.Next;
   begin
      pragma Assert (At_End_Borrow (X.Next.Next).Val = At_End_Borrow (Y).Val);
      pragma Assert (At_End_Borrow (X.Next.Next) /= null);

      pragma Assert (At_End_Borrow (X.Next.Next.Val) = 3);
      -- incorrect, X could be modified through Y

      pragma Assert (At_End_Borrow (X.Next) /= null);
      pragma Assert (At_End_Borrow (X).Val = 1);
      -- rejected by the tool, X and X.Next are not part of a borrowed expression

      X.Val := 42;
   end;

Here, like in the previous example, we can state in a pledge that
``X.Next.Next.Val`` is ``Y.Val``, and then ``X.Next.Next`` cannot be set to
null. We also cannot assume anything about the
part of ``X`` designated by ``Y``, so we won't be able to prove that
``X.Next.Next.Val`` will remain 3. Note that we cannot get the value at the
end of the borrow of an expression which is not borrowed in the current scope.
Here, even if ``X.Next.Next`` is borrowed, ``X`` and ``X.Next`` are not. As
a result, calls to ``At_End_Borrow`` on them will be rejected by the tool.

Inside the scope of ``Y``, it is possible to modify the variable ``Y`` itself,
as opposed to modifying the structure it designates, so that it gives access to
a subcomponent of the borrowed structure. It is called a reborrow. In case of
reborrow, the pledge of the borrower is modified so that it
relates the expression borrowed initially to the new borrower. For
example, let's use ``Y`` to borrow ``X`` entirely and then modify it to only
designate ``X.Next.Next``:

.. code-block:: ada

   declare
      Y : access List := X;
   begin
      Y := Y.Next.Next;

      pragma Assert (At_End_Borrow (X).Next.Next /= null);
      pragma Assert (At_End_Borrow (X).Val = 1);
      pragma Assert (At_End_Borrow (X).Next.Val = 2);
      pragma Assert (At_End_Borrow (X).Next.Next.Val = 3);      --  incorrect
      pragma Assert (At_End_Borrow (X).Next.Next.Next /= null); --  incorrect
   end;

After the assignment, the part of ``X`` still accessible from the borrower is
reduced, but since ``X`` was borrowed entirely to begin with, the ownership
policy of |SPARK| still forbids direct access to any components of ``X`` while
in the scope of ``Y``. As a result, we have a bit more information about the
final value of ``X`` than in the previous case. We still know that ``X``
will hold at least three elements, that is ``X.Next.Next /= null``.
Additionally, the first and second components of ``X`` are no longer accessible
from ``Y``, and since they cannot be accessed directly through ``X``, we know
that they will keep their current values. This is why we can now assert in a
pledge that ``X.Val`` is 1 and ``X.Next.Val`` is 2.

However, we still cannot know anything
about the part of ``X`` still accessible from ``Y`` as these properties
could be modified later in the borrow:

.. code-block:: ada

      Y.Val := 42;
      Y.Next := null;

At_End_Borrow functions are also useful in postconditions of borrowing traversal
functions. A borrowing traversal function is a function which returns a local
borrower of its first parameter. As |GNATprove| works modularly on a per
subprogram basis, it is necessary to specify the pledge of the result of such
a function in its postcondition, or proof would not be able to recompute the
value of the borrowed parameter after the returned borrower goes out of scope.

As an example, we can define a ``Tail`` function which returns the ``Next``
component of a list if there is one, and ``null`` otherwise:

.. code-block:: ada

   function Tail (L : access List) return access List is
   begin
      if L = null then
         return null;
      else
         return L.Next;
      end if;
   end Tail;

In its postcondition, we want to consider the two cases, and, in each case,
specify both the value returned by the function and how the
parameter ``L`` is related to the returned borrower:

.. code-block:: ada

   function Tail (L : access List) return access List with
     Contract_Cases =>
       (L = null =>
          Tail'Result = null and At_End_Borrow (L) = null,
        others   => Tail'Result = L.Next
          and At_End_Borrow (L).Val = L.Val
          and At_End_Borrow (L).Next = At_End_Borrow (Tail'Result));

If ``L`` is ``null`` then ``Tail`` returns ``null`` and ``L`` will stay ``null``
for the duration of the borrow. Otherwise, ``Tail`` returns ``L.Next``, the
first element of ``L`` will stay as it was at the time of call, and the rest
of ``L`` stays equal to the object returned by ``Tail``.

Thanks to this postcondition, we can verify a program which borrows a part of
``L`` using the ``Tail`` function and modifies ``L`` through this borrower:

.. code-block:: ada

   declare
      Y : access List := Tail (Tail (X));
   begin
      Y.Val := 42;
   end;

   pragma Assert (X.Val = 1);
   pragma Assert (X.Next.Val = 2);
   pragma Assert (X.Next.Next.Val = 42);
   pragma Assert (X.Next.Next.Next.Val = 4);

Accessing the Logical Equality for a Type
-----------------------------------------

In Ada, the equality is not the logical equality in general. In particular,
arrays are considered to be equal if they contain the same elements, even with
different bounds, +0.0 and -0.0 are considered equal...

It is possible to use a ``pragma Annotate (GNATprove, Logical_Equal)`` to ask
|GNATprove| to interpret a function with an equality profile as the logical
equality for the type. The function shall not have a body visisble in
|SPARK|: it can be left as non-executable (using ``Import``) or given an
(approximated) definition which can be used when executing contracts.
It comes in handy for example to express that a (part of a) data-structure
is left unchanged by a procedure, as is done in the example below:

.. code-block:: ada

   subtype Length is Natural range 0 .. 100;
   type Word (L : Length := 0) is record
      Value : String (1 .. L);
   end record;
   function Real_Eq (W1, W2 : String) return Boolean with
     Ghost,
     Import,
     Annotate => (GNATprove, Logical_Equal);
   type Dictionnary is array (Positive range <>) of Word;

   procedure Set (D : in out Dictionnary; I : Positive; W : String) with
     Pre  => I in D'Range and W'Length <= 100,
     Post => D (I).Value = W
     and then (for all J in D'Range =>
                 (if I /= J then Real_Eq (D (J).Value, D'Old (J).Value)))
   is
   begin
      D (I) := (L => W'Length, Value => W);
   end Set;

Note that, in general, |GNATprove| is not able to prove the `extensionality` of
the logical equality. For example, it will not be able to prove that two arrays
are logically equal even if they have the same bounds and the same value. It
is because it is not necessarily true in the underlying Why3 model, where,
for example, arrays have values outside of their bounds. Therefore, using an
assumption to state that two objects which are equal-in-Ada are logically equal
might introduce an unsoundness, in particular in the presence of slices. It is
demonstrated in the example below where |GNATprove| can prove that two strings
are not logically equal even though they have the same bounds and the same
elements. However, logical equality can be used safely as long as everything is
proved correct (no assumption is used).

.. code-block:: ada

   procedure Test is
      S1 : constant String := "foo1";
      S2 : constant String := "foo2";

   begin
      pragma Assert (S1 (1 .. 3) = S2 (1 .. 3));
      pragma Assert (not Real_Eq (S1 (1 .. 3), S2 (1 .. 3)));
   end Test;

with Loop_Types; use Loop_Types;
package Validation
  with SPARK_Mode
is

   function Is_Valid (C : Component_T) return Boolean is
      (C in 2 .. 5); --  arbitrary validation expression

   procedure Validate_Sequence (A : in Arr_T; Success : in out Boolean) with
     --  Note the use of boolean equality to describe exactly what the
     --  truth value of the flag (Success) should be
     Post => Success = (Success'Old and
                        (for all Index in A'Range => Is_Valid (A (Index))));

end Validation;

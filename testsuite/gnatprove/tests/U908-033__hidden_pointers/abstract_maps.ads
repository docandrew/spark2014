--  Introduce a non executable type for maps with size 0. It can be used to
--  model a ghost subprogram parameter or a ghost component.

generic
   type Key_Type is private;
   No_Key : Key_Type;
   type Object_Type (<>) is private;

package Abstract_Maps with SPARK_Mode is

   type Map is private with
     Default_Initial_Condition,
     Iterable => (First       => Iter_First,
                  Next        => Iter_Next,
                  Has_Element => Has_Key);

   function Has_Key (M : Map; K : Key_Type) return Boolean with
     Import,
     Post => (if Has_Key'Result then K /= No_Key);

   function Get (M : Map; K : Key_Type) return Object_Type with
     Import,
     Pre => Has_Key (M, K);

   --  For quantification only. Do not use to iterate through the map.
   function Iter_First (M : Map) return Key_Type with
     Import;
   function Iter_Next (M : Map; K : Key_Type) return Key_Type with
     Import;

private
   pragma SPARK_Mode (Off);
   type Map is null record;
end Abstract_Maps;

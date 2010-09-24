------------------------------------------------------------------------------
--                                                                          --
--                            GNAT2WHY COMPONENTS                           --
--                                                                          --
--                         W H Y - G E N - I N T S                          --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                       Copyright (C) 2010, AdaCore                        --
--                                                                          --
-- gnat2why is  free  software;  you can redistribute it and/or modify it   --
-- under terms of the  GNU General Public License as published  by the Free --
-- Software Foundation;  either version  2,  or  (at your option) any later --
-- version. gnat2why is distributed in the hope that it will  be  useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHAN-  --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details. You  should  have  received a copy of the GNU --
-- General Public License  distributed with GNAT; see file COPYING. If not, --
-- write to the Free Software Foundation,  51 Franklin Street, Fifth Floor, --
-- Boston,                                                                  --
--                                                                          --
-- gnat2why is maintained by AdaCore (http://www.adacore.com)               --
--                                                                          --
------------------------------------------------------------------------------

with Why.Unchecked_Ids;  use Why.Unchecked_Ids;
with Why.Atree.Builders; use Why.Atree.Builders;
with Why.Atree.Mutators; use Why.Atree.Mutators;
with Why.Gen.Types;      use Why.Gen.Types;
with Why.Gen.Names;      use Why.Gen.Names;
with Why.Gen.Funcs;      use Why.Gen.Funcs;
with Why.Gen.Arrows;     use Why.Gen.Arrows;

package body Why.Gen.Ints is

   procedure Define_Signed_Int_Conversions
     (File  : W_File_Id;
      Name  : String;
      First : Int;
      Last  : Int);

   ---------------------------------
   -- Declare_Abstract_Signed_Int --
   ---------------------------------

   procedure Declare_Abstract_Signed_Int
     (File : W_File_Id;
      Name : String;
      Size : Pos) is
   begin
      Declare_Abstract_Signed_Int (File,
                                   Name,
                                   -2 ** Natural (Size - 1),
                                   2 ** Natural (Size - 1)  - 1);
   end Declare_Abstract_Signed_Int;

   procedure Declare_Abstract_Signed_Int
     (File  : W_File_Id;
      Name  : String;
      First : Int;
      Last  : Int)
   is
      T : constant W_Type_Id := Declare_Abstract_Type (Name);
   begin
      File_Append_To_Declarations (File, New_Logic_Declaration (Decl => T));
      Define_Signed_Int_Conversions (File, Name, First, Last);
   end Declare_Abstract_Signed_Int;

   -----------------------------------
   -- Define_Signed_Int_Conversions --
   -----------------------------------

   procedure Define_Signed_Int_Conversions
     (File  : W_File_Id;
      Name  : String;
      First : Int;
      Last  : Int)
   is
      pragma Unreferenced (First);
      pragma Unreferenced (Last);
      --  ??? Not fully implemented yet

      Return_Type : constant W_Primitive_Type_Id := New_Abstract_Type (Name);
      Arrows      : W_Arrow_Type_Unchecked_Id :=
                      New_Arrow_Stack (Return_Type);
   begin
      Arrows := Push_Arg (Arrows, New_Identifier ("n"), New_Type_Int);
      Declare_Logic_And_Parameters (File,
                                    New_Conversion_To_Int (Name),
                                    Arrows);
   end Define_Signed_Int_Conversions;

end Why.Gen.Ints;

--------------------------------------------------------
--  This file was automatically generated by Ocarina  --
--  Do NOT hand-modify this file, as your             --
--  changes will be lost when you re-run Ocarina      --
--------------------------------------------------------
pragma Style_Checks
 ("NM32766");

with PolyORB_HI.Utils;
with System;
with PolyORB_HI_Generated.Deployment;

package PolyORB_HI_Generated.Naming is

  --  Naming Table for bus the_bus

  Naming_Table : constant PolyORB_HI.Utils.Naming_Table_Type :=
   (PolyORB_HI_Generated.Deployment.pr_A_K =>
     (PolyORB_HI.Utils.To_Hi_String
       ("127.0.0.1"),
      4001,
      System.null_Address),
    PolyORB_HI_Generated.Deployment.pr_B_K =>
     (PolyORB_HI.Utils.To_Hi_String
       ("127.0.0.1"),
      4002,
      System.null_Address),
    others =>
     (PolyORB_HI.Utils.To_Hi_String
       (""),
      0,
      System.null_Address));

end PolyORB_HI_Generated.Naming;

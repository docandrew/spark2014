procedure Main1 is

   procedure Dummy (X : Integer) is
      Tmp : Integer;
   begin
      pragma Assert (X /= 0);
   end;

   G : Integer := 0;

begin
   Dummy (G);
end;

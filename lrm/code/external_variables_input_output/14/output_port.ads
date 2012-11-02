package Output_Port
with
   Abstract_State => (Volatile => (Output => Outputs))
is
   procedure Write_To_Port(Output_Value : in Integer)
   with
      Global  => (Output => Outputs),
      Depends => (Outputs => Output_Value);
end Output_Port;

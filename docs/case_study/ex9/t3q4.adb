package body T3Q4
is

  function SumArray (A: in ArrayType) return SumType
  is
    Sum: SumType := 0;
  begin
    for I in IndexType loop
      pragma Loop_Invariant ((if I /= IndexType'First then Sum = Summed_Between(A, IndexType'First, I-1)) and
        Sum <= 1000 * (I - IndexType'First));
      Sum := Sum + A(I);
      --# assert Sum = Summed_Between(A, IndexType'First, I) and
      --#        Sum <= 1000 * (I - IndexType'First + 1);
    end loop;
    return Sum;
  end SumArray;

end T3Q4;

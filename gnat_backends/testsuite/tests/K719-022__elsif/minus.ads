package Minus is
   function Minus (X : Natural) return Natural
   with Pre => 1 <= X and X <= 3,
     Post => Minus'Result = X - 1;

end Minus;

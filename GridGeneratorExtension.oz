declare
fun{CreateMatrix Nrow Ncol}
   local CreateMatrixAAA CreateRow in
      fun{CreateRow}
	 local CreateRowAAA GenerateNum in
	    fun{CreateRowAAA Acc}
	       if{List.length Acc}<Ncol then
		  local Y  in
		     Y={GenerateNum}
		     {CreateRowAAA {List.append Acc Y|nil}}
		  end    
	       else
		  Acc
	       end
	    end
	    fun{GenerateNum}
	       local Z in
		  Z={OS.rand} mod 2
		  if Z==1 then
		     {OS.rand} mod 2
		  else
		     Z
		  end
	       end
	    end	       
	    {CreateRowAAA nil}
	 end
      end    
      fun{CreateMatrixAAA Acc Rows}
	 local X in
	    if Rows>0 then
	       X={CreateRow}
	       {CreateMatrixAAA {List.append Acc X|nil} Rows-1}
	    else
	       Acc
	    end
	 end	 
      end
      {CreateMatrixAAA [0] Nrow}.2 %pour plus avoir le 0
   end
end
{Browse {CreateMatrix 6 7}}
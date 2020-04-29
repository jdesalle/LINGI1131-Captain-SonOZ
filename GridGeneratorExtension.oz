declare
%This function can be used to generate a grid. In extremely rare cases it is possible that the generated map will be cut in two by island or that island will form a closed shape. Simply restart the function to fix this if it happens.
fun{CreateMatrix Nrow Ncol}
   local CreateMatrixAAA CreateRow in
      fun{CreateRow}% creates list of 1 and 0 randomly
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
	    fun{GenerateNum}%generates either a 1 or a 0 but more frequently 0
	       local Z in
		  Z={OS.rand} mod 2
		  if Z==1 then %If we feel we still have too many ones simply do an OS random a third time
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
      {CreateMatrixAAA [0] Nrow}.2 
   end
end
{Browse {CreateMatrix 4 4}}
declare
fun{CreateMatrix Nrow Ncol}
   local CreateMatrixAAA CreateRow in
      fun{CreateRow}% cree une liste de 0 et de 1 aleatoire
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
	    fun{GenerateNum} %genere soit un 1 soit un 0, mais plus souvent des 0
	       local Z in
		  Z={OS.rand} mod 2
		  if Z==1 then % on le fait une deuxième fois pour pas avoir trop de 1, si il y en a toujours trop il suffit de le faire une troisième fois
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
{Browse {CreateMatrix 4 4}}

   
local
   Stream
   fun{GetEnd Stream}
      case Stream of nil then nil
      []H|nil then H
      []H|T then {GetEnd T}
      end
   end
   
in
   
   local 
      fun{Test Acc}
	 thread
	    if Acc==10 then
	       nil
	    else
	       {Delay 1000}Acc|{Test Acc+1}
	    end
	 end
      end
 
      
   in
      Stream={Test 0}
    
      
      thread
	 {Browse Stream}
      end
      thread
	 local
	    End
	 in
	    End={GetEnd Stream}
	    {Browse End}
	 end
	 
      end
   end
end


		
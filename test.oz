
   
local
   Stream

in
   
   local 
      fun{Test Acc}
	 thread
	    if Acc==3 then
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
   end
end

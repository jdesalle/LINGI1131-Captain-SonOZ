functor
import
   GUI
   Input
   PlayerManager
   OS

define
   WindowPort

   
in
   thread
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
   end
end

functor
import
   GUI
   Input
   PlayerManager
   OS

define
   WindowPort

   
in
   
%---------------------Initialisation-----------
 
   thread
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
   end

%---------------Jeu-------------
   
   if(Input.isTurnByTurn) then
      %trucs pour le turn by turn
   end
   
   else 
 %Trucs pour le simultane
   end
   
end

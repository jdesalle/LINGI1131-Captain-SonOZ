functor
import
   GUI
   Input
   PlayerManager
   OS

define
   WindowPort
   PortsSubmarines
   CreatePortSubmarine
   
in
   
%---------------------Initialisation-----------
 
   thread
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
      
   end
   
%---------------Jeu-------------
   
   if(Input.isTurnByTurn) then
      %trucs pour le turn by turn
      
   else 
 %Trucs pour le simultane
  
   end

   %%------------Fonctions-initialisation-----
   %NOT YET WORKING
%    fun{CreatePortSubmarine}
%       fun{CreatePortSubmarineAAA Players Color ID}
% 	 case Subs of _|_ then
% 	    {PlayerManager.playerGenerator Players.1 player(id:ID color:Colors.1)}|CreatePortSubmarineAAA Players.2 Colors.2}
%          []nil then nil
%        end
%    end
% in
% {CreatePortSubmarineAAA Input.Players Input.Colors 2}
% end
end







































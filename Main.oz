functor
import
   GUI
   Input
   PlayerManager
   OS
   System
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
     % {System.show PortsSubmarines}
   end
   
%---------------Jeu-------------
   
 %   if(Input.isTurnByTurn) then
 %      %trucs pour le turn by turn
      
 %   else 
 % %Trucs pour le simultane
  
 %   end

   %%------------Fonctions-initialisation-----
   %create port for every player
   fun{CreatePortSubmarine}
      fun{CreatePortSubmarineAAA Subs Colors ID}
 	 case Subs of _|_ then
 	    {PlayerManager.playerGenerator Subs.1 Colors.1 ID}|{CreatePortSubmarineAAA Subs.2 Colors.2 ID+1}
 	 []nil then nil
 	 end
      end
   in
      {CreatePortSubmarineAAA Input.players Input.colors 1}
   end
 end

%create ids for every player 
fun{CreateIds}
   fun{CreateIdsAAA NbPlayers}

   end
end






































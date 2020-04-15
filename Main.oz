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
   CreateIds
   IdPlayers
   AvailablePositions
   Positions
   AssignSpawn
   
in
   
%---------------------Initialisation-----------
 
   thread
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
     %{System.show 'yeah'}    
      IdPlayers={CreateIds PortsSubmarines}
      Positions={AvailablePositions}
      {Send WindowPort initPlayer(IdPlayers.1 pt(x:1 y:1))}%Change to make random spawn 
      %{Send WindowPort drawMine(1|1|nil)}
      {System.show {AvailablePositions}} %couille car donne nil alors que ca devrait pas. Je vois pas mon erreur :(
   end
   

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

%create ids for every player and returns a list of ids
   fun{CreateIds Ports}
      case Ports of H|T then
	 local X in
	    {Send H getId(X)}
	    X|{CreateIds T}
	 end
      []nil then nil
      end
   end

 %WORK IN PROGRESS
%Returns a list of positions pt(x:X y:Y) where there is no island
   fun{AvailablePositions}
      fun{AvailablePositionsAAA Acc X Y List} 
	 case Acc of H|T then
	    if X==Input.nColumn then
	       if Acc.1\=1 then {AvailablePositionsAAA Acc.2 1 Y+1 List|pt(x:X y:Y)}
	       else
		  {AvailablePositionsAAA Acc.2 1 Y+1 List}
	       end
	    else
	       if Acc.1 \=1 then {AvailablePositionsAAA Acc.2 X+1 Y List|pt(x:X y:Y)}
	       else
		  {AvailablePositionsAAA Acc.2 X+1 Y List}
	       end
	    end	        
	 []nil then (List|nil).2 %on est au bout, on skip le premier element qui est nil
	 end
      end	  
   in
      {AvailablePositionsAAA {List.flatten Input.map} 1 1 nil}
   end
      

   %TO DO
   %Choisis des positions au hasard parmis la liste. S'assure que les spawns sont suffisament ecartes?
   %Retourne une liste de la longueur du nombre de joueurs 
   fun{AssignSpawn AvailablePositions}
      AvailablePositions.1 %A modifier
   end


end



%---------------Jeu-------------
   
 %   if(Input.isTurnByTurn) then
 %      %trucs pour le turn by turn
      
 %   else 
 % %Trucs pour le simultane
  
 %   end

































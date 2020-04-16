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
   PickRandom
   
in
   
%---------------------Initialisation-----------
 
   thread
     % {System.show 'Yeah Yeah'}
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
      IdPlayers={CreateIds PortsSubmarines}
      Positions={AvailablePositions}%position ou il n'y a pas d'iles
      {Send WindowPort initPlayer(IdPlayers.1 pt(x:1 y:1))}%Change to make random spawn 
      %{Send WindowPort drawMine(1|1|nil)}
      {System.show 'PickRandom Test'}
      {System.show {PickRandom Positions}}
      {System.show {AssignSpawn Positions}}
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
	    {Send H getId(X)}%il faut definir getId dans player
	    X|{CreateIds T}
	 end
      []nil then nil
      end
   end

%Returns a list of positions pt(x:X y:Y) where there is no island
   %Je suis pas sur que ce soit dans le main qu'il faille le mettre
   fun{AvailablePositions}
      fun{AvailablePositionsAAA Acc X Y Result} 
	 case Acc of H|T then
	    if X>=Input.nColumn then
	       if Acc.1\=1 then {AvailablePositionsAAA Acc.2 1 Y+1 {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 1 Y+1 Result}
	       end
	    else
	       if Acc.1 \=1 then {AvailablePositionsAAA Acc.2 X+1 Y {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 X+1 Y Result}
	       end
	    end	        
	 []nil then
	    Result.2 %on est au bout, on skip le premier element qui est 000
	 end
      end	  
   in     
      local Res in
	 Res={AvailablePositionsAAA {List.flatten Input.map} 1 1 000|nil}
	 Res
      end    
   end
      

   %Choisis des positions au hasard parmis la liste de positions sans iles
   %Retourne une liste de la longueur du nombre de joueurs
   %de nouveau je suis pas sur que ce soit dans le main qu'il faille le mettre
   fun{AssignSpawn AvailablePositions}
      fun{AssignSpawnAAA Len Liste}
	 local Random Acc in
	    Random={PickRandom AvailablePositions}
	    Acc={List.append Liste Random|nil}
	    if Len>0 then {AssignSpawnAAA Len-1 Acc}
	    else
	       Liste.2 %On skippe le 000
	    end
	 end	
      end      
   in
      {AssignSpawnAAA Input.nbPlayer 000|nil}
   end
   
   %prends un element au hasard dans une liste
   fun{PickRandom Liste}
      local Num Len in
	 Len={List.length Liste}
	 Num=({OS.rand} mod Len)+1
	 {List.nth Liste Num}%Prends le Num element de la liste
      end      
   end
   
end



%---------------Jeu-------------
   
 %   if(Input.isTurnByTurn) then
 %      %trucs pour le turn by turn
      
 %   else 
 % %Trucs pour le simultane
  
 %   end

































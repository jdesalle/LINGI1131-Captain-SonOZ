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
   
in
   
%---------------------Initialisation-----------
 
   thread
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
     {System.show PortsSubmarines}
      IdPlayers={CreateIds PortsSubmarines}
      {System.show IdPlayers}
      {System.show 42}
      {Send WindowPort initPlayer(IdPlayers.1 1|2)}
      {System.show 43}
      %{Send WindowPort drawMine(1|1|nil)}
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

%create ids for every player 
   fun{CreateIds Ports}
      case Ports of H|T then
	 local X in
	    {Send H getId(X)} %pour que ca marche il faut ajouter une fonction GetId dans player et traiter le cas getId(X) dans la fonction TreatStream de player
	    X|{CreateIds T}
	 end
      []nil then nil
      end
   end
end





%---------------Jeu-------------
   
 %   if(Input.isTurnByTurn) then
 %      %trucs pour le turn by turn
      
 %   else 
 % %Trucs pour le simultane
  
 %   end

































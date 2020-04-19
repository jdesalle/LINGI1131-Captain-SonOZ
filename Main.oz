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
   Spawns
%%%StateFunction
   StateList
   SetState%%%%to set the state
   InitStateList %%%initiate StateList from portlist
   UpdatePosDir
   UpdateSurf
   UpdateItem
   UpdateFire
   UpdateMine
   
   Broadcast
   BroadcastFire
   %%Partie tour par tour
   PartieTT
   Turn
in
%%%%%create a state from the differents agruments
   fun{SetState ID Port Position FormerPositions Surface Items Charges}
      state(id:ID port:Port position:Position formerPos:FormerPositions surface:Surface items:Items charges:Charges)
   end
   fun{UpdatePosDir ID Direction StateList}
      case StateList of nil then StateList%%%no modification, invalid Id maybe put an error message
      []H|T then
	 if H.id==ID then
	    case Direction of east then
	       {SetState H.id H.port position(H.position.x H.position.y+1) H.position|H.formerPos H.surface H.items H.charges}
	    []north then
	       {SetState H.id H.port position(H.position.x-1 H.position.y) H.position|H.formerPos H.surface H.items H.charges}
	    []south then
	       {SetState H.id H.port position(H.position.x+1 H.position.y) H.position|H.formerPos H.surface H.items H.charges}
	    []west then
	       {SetState H.id H.port position(H.position.x H.position.y-1) H.position|H.formerPos H.surface H.items H.charges}
	    []_ then %%%ici, ce sera le cas ou il s'agit d'une mauvaise direction, on ignore simplement, eventuellement un message d'erreur
	       StateList
	    end
	 else
	    {UpdatePosDir ID Direction T}
	 end
      end
   end
   fun{UpdateSurf ID StateList}
%%%%TO DO
      StateList
   end
   fun{UpdateItem ID KindItem StateList}
%%%%%%TO DO
      StateList
   end
   fun{UpdateFire ID KindFire StateList}
%%%%%%%TO DO
      StateList
   end
   fun{UpdateMine ID Mine StateList}
%%%%%TO DO
      StateList
   end   
   
   %%create a list of state from the port open and the availables positions
%%%%%Still need to use position to choose a random position for each submarine
   fun{InitStateList PortList Spawns}
      local
	 fun{InitStateList PortList Acc Spawns}
	    case PortList of nil then nil
	    []H|T then
%%%randomgenPosition:done %COUILLE avec les spawns, c'est le player qui les gere, il faut changer ca ici-> on va retirer le Sapwn d'ici et modifier la fonction d'appel, ca devrai "vite" se corriger .
	       {SetState Acc H Spawns.1 nil surface(surface:true timeLeft:0) null charges(mines:0 missile:0 sonar:0 drone:0)}|{InitStateList T Acc+1 Spawns.2} 
	    end                                                                                                          
	 end
      in
	 case PortList of nil then nil
	 []H|T then
%%%%%randomgenPosition:done
	    {SetState 0 H Spawns.1 nil surface(surface:true timeLeft:0) null charges(mines:0 missile:0 sonar:0 drone:0)}|{InitStateList T 1 Spawns.2}
	 end
      end
   end
   
		      
	    
   
%---------------------Initialisation-----------
 
   thread
      {System.show 'Main Thread Started'}
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
      Positions={AvailablePositions}%position ou il n'y a pas d'iles
      Spawns={AssignSpawn Positions}% une liste de longueur nbPlayers de spawns generes aleatoirement
      StateList={InitStateList PortsSubmarines Spawns}
      {System.show 'StateList and above Initialized'}
     % {Send WindowPort initPlayer(IdPlayers.1 pt(x:1 y:1))}%Change to make random spawn. FAILS because IdPlayer not defin
      {Send WindowPort putMine(1 pt(x:1 y:1))}%does nothing idk why
      {Send PortsSubmarines.1 sayMove(1 'east')}
      {System.show 'Reached end of main thread sucessfully'}
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
   
   proc{Broadcast Message StateList}
      case StateList of nil then skip
      []H|T then
	 {Send H.port Message}
	 {Broadcast Message T}
      end
   end
   proc{BroadcastFire KindFire StateList}
      %% TO DO
      {Broadcast KindFire StateList}%%%%not the real proc
   end
   
   fun{Turn State StateList}
      if State.surface.timeLeft>0 then
	 StateList
      else
	 if State.formerPos == nil then
	    {Send State.port dive}
	 end
	 local
	    Position Direction StateMove
	 in
	    {Send State.port move(State.id Position Direction)}
	    if Direction== surface then
	       {Broadcast saySurface(State.id) StateList}
	       {UpdateSurf State.id StateList} %updatesurf pas encore codé, pour el moment aucun changement dans la statelist
	    else 
	       {Broadcast sayMove(State.id Direction) StateList}
	       StateMove={UpdatePosDir State.id Direction StateList}
	       local
		  KindItem StateItem
	       in 
		     {Send State.port charge(State.id KindItem)}
		  if KindItem \= null then
		     StateItem={UpdateItem State.id KindItem StateMove}
		     {Broadcast sayCharge(State.id KindItem) StateList}
		  else
		     StateItem=StateMove
		  end
		  local
		     StateFire KindFire
		  in
		     {Send State.port fireItem(State.id KindFire)}
		     if KindFire \= null then
			StateFire={UpdateFire State.id KindFire StateItem}
			{BroadcastFire KindFire StateList}
		     else
			StateFire=StateItem
		     end
		     local
			StateMine Mine Message
		     in
			if Mine \=null then
			   StateMine={UpdateMine State.id Mine StateFire}
			   {Broadcast sayMineExplode(State.id Mine Message) StateItem}
			else
			   StateMine=StateFire
			end
			StateMine%%%renvoit de l'état final après toute les étape du tour.
		     end
		  end
	       end
	    end
	 end
      end
   end
   
%%%%%%%En Cours
	 



%---------------Jeu-------------
   
  % thread%J'ai rajoute un thread, pas sur qu'il faille je crois pas, a moins qu'a un moment on implémente la possibilité de jouer plusieur partie, et alors il serait avant
   if(Input.isTurnByTurn) then
      local
	 Result
	 fun{PartieTT StateList}
	    local
	       fun{GiveTurn ToCompute StateList}
		  case ToCompute of nil then StateList
		  []H|T then {GiveTurn T {Turn H StateList}}
		  end
	       end
	    in
	       case StateList of nil then StateList%%%fin partie
	       []H|nil then StateList %%fin partie avec H= vainqueur
	       []H|T then
		  {PartieTT {GiveTurn T {Turn H StateList}}}
%%%{Turn H Statelist} make the tour of submarine of state H and send an updated StateList
		  %%Give turn Aply Turn to each State of The remaining state list and return the updated Statelist
	       end
	    end
	 end
      in
	 Result={PartieTT StateList}
      end  
   else 
 %Trucs pour le simultane
      skip
   end
   


end%En du define tout ce qui est au dessus doit etre indente une fois!!!!

    






























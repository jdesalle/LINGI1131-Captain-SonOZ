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
   UpdateSurf
   Alive
   
   
   Broadcast
   BroadcastFire
   BroadcastMine
   %%Partie tour par tour
   PartieTT
   PartieSS
   Turn
in
%%%%%create a state from the differents agruments
   fun{SetState ID Port Surface}
      state(id:ID port:Port surface:Surface)
   end
   
   fun{UpdateSurf ID StateList}
      case StateList of nil then nil
      []H|T then
	 if H.id==ID
	    if H.surface.timelef==0 then
	       {SetState H.id H.port surface(surface:true timeLeft:Input.TurnSurface)}|T
	    else
	       {SetState H.id H.port surface(surface:true timeLeft:H.surface.timeLeft-1)}|T
	    end
	 else
	    H|{UpdateSurf ID T}
	 end
      end
   end
   fun{Alive StateList Deads}
      local
	 fun{CheckDead ID Deads}
	    case Deads of nil then false
	    []H|T then
	       if ID==H.id then true
	       else
		  false
	       end
	    end
	 end
      in
	 case StateList of nil then nil
	 []H|T then
	    if {CheckDead ID Deads}==true then
	       T
	    else
	       H|{Alive T Deads}
	    end
	 end
      end
   end
   
   
   
   
   %%create a list of state from the open ports %%%maybe have to modify this one for the ID? 
   fun{InitStateList PortList}
      local
	 fun{InitStateList Acc PortList}
	    case portList of nil then nil
	    []H|T then
	       {SetState Acc H surface(surface:true timeLeft:0)}|{InitStateList Acc+1 T}
	    end
	 end
      in
	 case PortList of nil then nil
	 []H|T then
	    {SetState 0 H surface(surface:true timeLeft:0)}|{InitStateList 1 T}
	 end
      end
   end
		      
   
   
%---------------------Initialisation-----------
 
   thread
      {System.show 'Main Thread Started'}
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      PortsSubmarines={CreatePortSubmarine}
      StateList={InitStateList PortsSubmarines}
      {System.show 'StateList and above Initialized'}
     % {Send WindowPort initPlayer(IdPlayers.1 pt(x:1 y:1))}%Change to make random spawn. FAILS because IdPlayer not defin
      {Send WindowPort putMine(1 pt(x:1 y:1))}%does nothing idk why
      {Send PortsSubmarines.1 sayMove(1 'east')}
      {System.show 'Reached end of main thread sucessfully'}
   end
   
   
   %%------------Fonctions-initialisation-----
   %create port for every player (submarine)
   fun{CreatePortSubmarine}
      fun{CreatePortSubmarineAAA Subs Colors ID}
	 case Subs of _|_ then
	    {PlayerManager.playerGenerator Subs.1 Colors.1 ID}|{CreatePortSubmarineAAA Subs.2 Colors.2 ID+1}
	 []nil then nil
	 end
      end
   in
      {CreatePortSubmarineAAA Input.players Input.colors 1} %couille ici avec les couleurs et les id, c'est lee player generator qui les assigne donc a priori pas besoin d'eux ici?
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
	 %%%%%%ici case of pour GUI
      end
   end
   fun{BroadcastFire KindFire StateList}
      %% TO DO
      StateList
   end
   fun{BroadcastMine StateList}
      %%% TO DO
      StateList
   end

   fun{Turn State StateList S}%%%TODO add thinking if S is true
      if State.surface.timeLeft>0 then
	 result(surface:true deads:nil)
      else
	 if State.surface.surface==true then
	    {Send State.port dive}
	 end
	 local
	    Position Direction
	 in
	    {Send State.port move(State.id Position Direction)}
	    if Direction== surface then
	       {Broadcast saySurface(State.id) StateList}
	       result(surface:true deads:nil)
	    else 
	       {Broadcast sayMove(State.id Direction) StateList}
	       local
		  KindItem StateItem
	       in 
		  {Send State.port charge(State.id KindItem)}
		  if KindItem \= null then
		     {Broadcast sayCharge(State.id KindItem) StateList}
		  end
		  local
		     KindFire Dead1
		  in
		     {Send State.port fireItem(State.id KindFire)}
		     if KindFire \= null then
			Dead1={BroadcastFire KindFire StateList}
		     else
			Dead1=nil
		     end
		     local
			Mine Message
		     in
			if Mine \=null then
			   Dead={BroadcastMine Mine {Alive Statelist Dead1}}
			else
			   Dead=Dead1
			end
			   result(surface:false deads:Dead)
		     end
		  end
	       end
	    end
	 end
      end
   end
   
   
   fun{PartieTT}

   end
   fun{PartieSS}
   end
   
	 



%---------------Jeu-------------
   
  % thread%J'ai rajoute un thread, pas sur qu'il faille je crois pas, a moins qu'a un moment on implémente la possibilité de jouer plusieur partie, et alors il serait avant
   if(Input.isTurnByTurn) then
      {PartieTT StateList}
   else 
      {PartieSS StateList
   end
   


end%En du define tout ce qui est au dessus doit etre indente une fois!!!!

    






























functor
import
   GUI
   Input
   PlayerManager
   System
define
   WindowPort
   PortsSubmarines
   CreatePortSubmarine
%%%StateFunction
   StateList
   SetState%%%%to set the state
   InitStateList %%%initiate StateList from portlist
   UpdateSurf
   Alive
   ProcessStream
   GetFinalState
   %BroadCast's
   Broadcast
   BroadcastFire
   BroadcastMine
   %%Partie tour par tour
   PartieTT
   PartieSS
   Turn
in
   %%------------Fonctions-initialisation-----
   %create port for every player (submarine)
   fun{CreatePortSubmarine}
      local
	 {PlayerManager.playerGenerator Subs.1 Color ID}|{CreatePortSubmarineAAA Subs.2}
   end%%%Return list of States-> state(id:EBNFID port:PLAYERPORT surface:SURFACEITEM)  Surface -> surface(surface: BOOL turnLeft:INT)

%-----------------States Functions----------------
%%%%%create a state from the differents agruments
   fun{SetState ID Port Surface}
      state(id:ID port:Port surface:Surface)
   end

   fun{UpdateSurf ID StateList}
      case StateList of nil then nil
      []H|T then
	 if H.id==ID then
	    if H.surface.timeLeft==0 then
	       {SetState H.id H.port surface(surface:true timeLeft:Input.turnSurface)}|T
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
	    []H|_ then
	       if ID==H.id then true
	       else
		  false
	       end
	    end
	 end
      in
	 case StateList of nil then nil
	 []H|T then
	    if {CheckDead H.id Deads}==true then
	       {Alive T Deads}
	    else
	       H|{Alive T Deads}
	    end
	 end
      end
   end
   
   
 %------------Broadcats functions-----------------
   proc{Broadcast Message StateList}
      case StateList of nil then skip
      []H|T then
	 {Send H.port Message}
	 {Broadcast Message T}
      end
   end
   fun{BroadcastFire ID KindFire StateList WindowPort}
      case KindFire of nil then nil
      []missile(Position) then
	 case StateList of nil then nil
	 []H|T then
	    local
	       Message
	    in
	       {Send H.port sayMissileExplode(ID Position Message)}
	       case Message of nil then {BroadcastFire ID KindFire T WindowPort}
	       []sayDeath(Dead)then
		  {Broadcast Message StateList}
		  Dead|{BroadcastFire ID KindFire T WindowPort}
	       []sayDamageTaken(Infos) then
		  {Broadcast Message StateList}
		  {BroadcastFire ID KindFire T WindowPort}
	       end
	    end
	 end
      []mine(Position) then
	 {Broadcast sayMinePlaced(ID)StateList}
	 nil
      []drone then
	 local
	    Answer
	 in
	    case StateList of nil then nil
	    []H|T then
	       {Send H.port sayPassingDrone(drone H.id Answer)}
	       {Send ID sayAnswerDrone(drone H.id Answer)}
	       {BroadcastFire ID KindFire T WindowPort}
	    end
	 end
      []sonar then
	 local
	    Answer
	 in
	    case StateList of nil then nil
	    []H|T then
	       {Send H.port sayPassingSonar(sonar H.id Answer)}
	       {Send ID sayAnswerSonar(sonar H.id Answer)}
	       {BroadcastFire ID KindFire T WindowPort}
	    end
	 end
      else
	 nil
      end
   end
   fun{BroadcastMine ID  Mine StateList WindowPort}
      case StateList of nil then nil
      []H|T then
	 local
	    Message
	    in
	    {Send H.port sayMineExplode(ID Mine Message)}
	    case Message of nil then {BroadcastMine ID Mine T WindowPort}
	    []sayDeath(Dead)then
	       {Broadcast Message StateList}
	       Dead|{BroadcastMine ID Mine T WindowPort}
	       []sayDamageTaken(Infos) then
	       {Broadcast Message StateList}
	       {BroadcastMine ID Mine T WindowPort}
	    end
	 end
      end
   end

   %------------Stream Process Functions-----------------
   fun{ProcessStream Stream StateList}
      case Stream of nil then StateList
      []H|T then
	 local Surf
	 in
	    if H.surface==true then
	       Surf= {UpdateSurf H.id StateList}
	    else
	       Surf=StateList
	    end
	    {ProcessStream T {Alive StateList H.deads}}
	 end
      end
   end
   fun{GetFinalState Stream}
      case Stream of nil then nil
      []H|nil then H
      []_|T then {GetFinalState T}
      end
   end
%---------------Turn and games Function---------------
   fun{Turn State StateList WindowPort S}%%%TODO add thinking if S is true
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
	       {Send WindowPort movePlayer(State.id Direction)}
	       local
		  KindItem
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
			Dead1={BroadcastFire State.id KindFire StateList WindowPort}
		     else
			Dead1=nil
		     end
		     local
			Mine Dead
		     in
			if Mine \=null then
			   Dead={BroadcastMine State.id Mine {Alive StateList Dead1} WindowPort}
			else
			   Dead=Dead1
			end
			   result(surface:false deads:Dead id:State.id)
		     end
		  end
	       end
	    end
	 end
      end
   end
   fun{PartieTT StateList WindowPort}
      local
	 fun {GetTurn Current StateList WindowPort}
	    case StateList of nil then {PartieTT StateList WindowPort}
	    []H|T then
	       local Result Surf in
		  Result= {Turn H StateList WindowPort false}
		  if Result.surface==true then
		     Surf={Alive {UpdateSurf H.id StateList} Result.deads}
		  else
		     Surf={Alive StateList Result.deads}
		  end
		  {GetTurn {Alive T Result.deads} Surf WindowPort}
	       end
	    end
	 end
      in
	 case StateList of nil then nil
	 []H|nil then H
	 []_|_ then
	    {GetTurn StateList StateList WindowPort}
	 end
      end
   end
   fun{PartieSS StateList WindowPort}
      local
	 Stream Stream2
      in
	 local
	    Final
	    fun{OpenThreads Current StateList WindowPort}
	       case StateList of nil then nil
	       []H|T then
		  thread
		     {Turn H StateList WindowPort true}|{OpenThreads T StateList WindowPort}
		  end
	       end
	    end
	 in
	    case StateList of nil then nil
	    []H|nil then H
	    []_|_ then
	       Stream={OpenThreads StateList StateList WindowPort}
	       thread
		  Stream2={ProcessStream Stream StateList}
	       end
	       thread
		  Final={GetFinalState Stream2}
	       end

	       {PartieSS Final WindowPort}
	    end
	 end
      end
   end
%---------------------Initialisation-----------
%%%after this: WindowPort Built, PortsSubmarines=List of Subma StateList=doublon?
   thread
      {System.show 'Main Thread Started'}
      WindowPort={GUI.portWindow}
      {Send WindowPort buildWindow}
      Statelist={CreatePortSubmarine}
      {System.show 'StateList and above Initialized'}
      {System.show 'Reached end of main thread sucessfully'}
   end
%---------------Jeu-------------
   local
      Winner
   in
      if(Input.isTurnByTurn) then
	 Winner={PartieTT StateList WindowPort}
      else
	 Winner={PartieSS StateList WindowPort}
      end
   end
end

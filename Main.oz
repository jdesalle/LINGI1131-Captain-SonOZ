functor
import
   GUI
   Input
   PlayerManager
   System
define
   WindowPort
   CreatePortSubmarine
   InitPosition
%%%StateFunction
   StateList
   SetState
   UpdateSurf
   Alive
   ProcessStream
   GetFinalState
   %BroadCast's
   Broadcast
   BroadcastFire
   BroadcastMine
   %%Parties and related functions
   PartieTT
   PartieSS
   
   SimulateThinking
   Turn
   Move
   Charge
   Mine
   Fire
in
   %%------------Fonctions-initialisation-----
   %create port for every player (submarine)
   fun{CreatePortSubmarine}
      local
	 fun{CreatPortSubmarine Acc}
	    local
	       Color Name Port
	    in
	       if Acc<Input.nbPlayer then
		  Name={List.nth Input.players Acc+1}
		  Color={List.nth Input.colors Acc+1}
		  Port={PlayerManager.playerGenerator Name Color Acc}
		  surface(id:id(id:Acc color:Color name:Name) port:Port surface:surface(surface:true timeLeft:0))|{CreatPortSubmarine Acc+1}
	       else
		  nil
	       end
	    end
	 end
      in
	 {CreatPortSubmarine 0}
      end
   end%%%Return list of States-> state(id:ID port:PLAYERPORT surface:SURFACEITEM)  Surface -> surface(surface: BOOL timeLeft:INT)
   proc{InitPosition StateList}
      case StateList of nil then skip
      []H|T then
	 local ID Position in
	    {Send H.port initPosition(ID Position)}
	    {Send WindowPort initPlayer(ID Position)}
	    {InitPosition T}
	 end
      end
   end
   
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
	       {SetState H.id H.port  surface(surface:true timeLeft:Input.turnSurface)}|T
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
	    if ID==null then
	       true
	    else
	       case Deads of H|T then
		  {System.show H.id}
		  {System.show ID.id}
		  {System.show H.id==ID.id}
		  if ID.id==H.id then true
		  else
		     {CheckDead ID T}
		  end
	       []nil then false
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
   fun{BroadcastFire ID KindFire Port StateList}
      case KindFire of nil then nil
      []missile(Position) then
	 case StateList of nil then nil
	 []H|T then
	    local
	       Message
	    in
	       {Send H.port sayMissileExplode(ID Position Message)}
	       case Message of null then {BroadcastFire ID KindFire Port T}
	       []sayDeath(ID2)then
		  {Broadcast Message StateList}
		  {Send WindowPort lifeUpdate(ID2 0)}
		  {Send WindowPort removePlayer(ID2)}
		  ID2|{BroadcastFire ID KindFire Port T}
	       []sayDamageTaken(ID2 Damage LifeLeft) then
		  {Send WindowPort lifeUpdate(ID2 LifeLeft)}
		  {Broadcast Message StateList}
		  {BroadcastFire ID KindFire Port T}
	       end
	    end
	 end
      []mine(Position) then
	 {Broadcast sayMinePlaced(ID) StateList}
	 {Send WindowPort putMine(ID Position)}
	 nil
      []drone then
	 local
	    Answer ID
	 in
	    case StateList of nil then nil
	    []H|T then
	       {Send H.port sayPassingDrone(drone ID Answer)}
	       {Send Port sayAnswerDrone(drone H.id Answer)}
	       {BroadcastFire ID KindFire Port T}
	    end
	 end
      []sonar then
	 local
	    Answer ID
	 in
	    case StateList of nil then nil
	    []H|T then
	       {Send H.port sayPassingSonar(ID Answer)}
	       {Send Port sayAnswerSonar(sonar ID  Answer)}
	       {BroadcastFire ID KindFire Port T}
	    end
	 end
      else
	 nil
      end
   end
   fun{BroadcastMine ID  Mine StateList}
      case StateList of nil then nil
      []H|T then
	 local
	    Message
	    in
	    {Send H.port sayMineExplode(ID Mine Message)}
	    {Send WindowPort explosion(ID Mine)}
	    {Send WindowPort removeMine(ID Mine)}
	    case Message of null then {BroadcastMine ID Mine T}
	    []sayDeath(ID2)then
	       {Send WindowPort lifeUpdate(ID2 0)}
	       {Send WindowPort removePlayer(ID2)}
	       {Broadcast Message StateList}
	       ID2|{BroadcastMine ID Mine T}
	    []sayDamageTaken(ID2 Damage LifeLeft) then
	       {Send WindowPort lifeUpdate(ID2 LifeLeft)}
	       {Broadcast Message StateList}
	       {BroadcastMine ID Mine T}
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

   fun{Move Port StateList}
       local
	    Position Direction ID
	 in
	  {Send Port move(ID Position Direction)}
	  if ID \=null then
	     {Send WindowPort movePlayer(ID Position)}
	     if Direction == 'surface' then
		{Send WindowPort surface(ID)}
		{Broadcast saySurface(ID) StateList}
		false	     
	     else
		{Broadcast sayMove(ID Direction) StateList}
		true	    
	     end
	  else
	     false
	  end
       end
   end
   proc{Charge Port StateList}
       local
	  ID KindItem
       in
	  {Send Port chargeItem(ID KindItem)}
	  if KindItem \= null then
	     {Broadcast sayCharge(ID KindItem) StateList}
	  end
       end
   end
   fun{Fire Port StateList}
       local
	  KindFire  ID
       in
	  {Send Port fireItem(ID KindFire)}
	  if ID \=null then
	     if KindFire \= null then
		{Alive StateList {BroadcastFire ID KindFire Port StateList}}
	     else
		StateList
	     end
	  else
	     StateList
	  end
       end
   end
   fun{Mine Port Dead1}
      local
	 Mine ID
      in
	 {Send Port fireMine(ID Mine)}
	 if ID\=null then
	    if Mine \=null then
	       {BroadcastMine ID Mine Dead1}
	    else
	       nil
	    end
	 else
	    nil
	 end
      end
   end
   fun{Turn State StateList S}%%%TODO add thinking if S is true
      if State.surface.timeLeft>0 then
	 result(surface:true deads:nil id:State.id)
      else
	 if State.surface.surface==true then
	    {Send State.port dive}
	 end
	 if S then
	    {SimulateThinking}
	 end
	 if{Move State.port StateList } ==false then
	    result(surface:true deads:nil id: State.id)
	    else
	    if S then
	       {SimulateThinking}
	    end
	    {Charge State.port StateList}
	     if S then
		{SimulateThinking}
	     end
	    local Dead1 Dead in
	       Dead1={Fire State.port StateList}
	        if S then
		   {SimulateThinking}
		end
	       Dead={Mine State.port Dead1}
	       result(surface:false deads:Dead id:State.id)
	    end
	 end	    
      end
   end
   proc{SimulateThinking}
        {Delay Input.thinkMin}
   end
     
   fun{PartieTT StateList}
      local
	 fun {GetTurn Current StateList}
	    case Current of nil then {PartieTT StateList}
	    []H|T then
	       local Result Surf in
		  Result= {Turn H StateList false}
		  {Delay Input.guiDelay}
		  if Result.surface==true then
		     Surf={Alive {UpdateSurf H.id StateList} Result.deads}
		  else
		     Surf={Alive StateList Result.deads}
		  end
		  {GetTurn {Alive T Result.deads} Surf}
	       end
	    end
	 end
      in
	 case StateList of nil then nil
	 []H|nil then H
	 []H|T then
	    {GetTurn StateList StateList}
	 end
      end
   end
   fun{PartieSS StateList}
      local
	 Stream Stream2
      in
	 local
	    Final
	    fun{OpenThreads Current StateList}
	       case Current of nil then {PartieSS StateList}
	       []H|T then
		  thread
		     {Turn H StateList true}|{OpenThreads T StateList}
		  end
	       end
	    end
	 in
	    case StateList of nil then nil
	    []H|nil then H
	    []H|T then
	       Stream={OpenThreads StateList StateList}
	       thread
		  Stream2={ProcessStream Stream StateList}
	       end
	       thread
		  Final={GetFinalState Stream2}
	       end

	       {PartieSS Final}
	    end
	 end
      end
   end
%---------------------Initialisation-----------

   
   {System.show 'Main Thread Started'}
   WindowPort={GUI.portWindow}
   {Send WindowPort buildWindow}
   StateList={CreatePortSubmarine}%state(ID PORT SURFACE)|...|nil    surface(surface:Bool timeLeft:Int)
   {InitPosition StateList}
   {Delay Input.guiDelay*10}
   {System.show 'Player  initialized in GUI'}
   {System.show 'Initialization completed sucessfully'}
%---------------Jeu-------------
   local
      Winner
   in
      {System.show 'Begin Game'}
      if(Input.isTurnByTurn) then
	 {System.show 'Turn by Turn Game'}
	 Winner={PartieTT StateList}
      else
	 {System.show 'Simultaneous Game'}
	 Winner={PartieSS StateList}
      end
      if Winner==nil then
	 {System.show 'Everyone is dead!'}
      else
	 {System.show 'Winner:'}
	 {System.show Winner}
      end
   end
end

functor
import
   Input
   System
   OS
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream

   InitPosition
   Move
   Dive
   ChargeItem
   FireItem
   FireMine
   IsDead
   SayMove
   SaySurface
   SayCharge
   SayMinePlaced
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayAnswerDrone
   SayPassingSonar
   SayAnswerSonar
   SayDeath
   SayDamageTaken
   %Added By me
   PlayerID=1
   ModifState
   AvailablePositions
   PickRandom
   Spawn
   PositionsAva
in

   thread
      PositionsAva={AvailablePositions}%position ou il n'y a pas d'iles
      Spawn={PickRandom PositionsAva}% un spawn choisi au hasard
   end
   

   
   %state:WhereMove charges(sonar:Int missile:Int mine:Int drone:Int) CurrentPos
   proc{TreatStream Stream State} % as as many parameters as you want
      case Stream of initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	 {TreatStream T {InitPosition ID Position} State}

	 
	 %----------------Actions---------Work in progress...
      []move(ID Position Direction)|T then
	 {TreatStream {Move ID Position Direction} State}
      []dive|T
      then skip
      []chargeItem(ID KindItem)|T
      then skip
      []fireItem(ID KindFire)|T
      then skip
      []fireMine(ID Mine)|T
      then skip
      []isDead(Answer)|T
      then skip
      %--------------Messages--WIP
	 
      []sayMove(ID Direction)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction} State}
	 end
      []saySurface(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SaySurface ID} State }
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayCharge ID KindItem} State}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMinePlaced ID} State}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMissileExplode ID} State}
	 end
      []sayMineExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMineExplode ID Position Message} State}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingDrone Drone ID Answer} State}
	 end
      []sayAnswerDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerDrone Drone ID Answer} State}
	 end
      []sayPassingSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingSonar ID Answer} State}
	 end
      []sayAnswerSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerSonar ID Answer} State}
	 end	 
      []sayDeath(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDeath ID} State}
	 end
      []sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDamageTaken ID Damage LifeLeft} State}
	 end
      end
   end


   %----------------------------------------------------
   %------------Fonctions Initialisation----------------
   %----------------------------------------------------
   fun{StartPlayer Color ID}
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
	 {TreatStream Stream State}
      end
      Port
   end


   fun{InitPosition ID Position}
      ID=PlayerID
      Position=Spawn
   end


   %-------------------------------------------------
   %-------Fonctions pour les messages:--------------
   %-------------------------------------------------
   proc{SayMove ID Direction}
      {System.show 'Player of ID:'#ID#'is moving'#Direction#'!'}
   end


   %----------------------------------------------
   %-----Fonctions pour les actions:--------------
   %----------------------------------------------
   %Si on peut aller a droite on y va, sinon on va en bas.
   %Si on sais plus aller en bas on teste la droite, sinon la gauche.
   
   proc{Move ID Position Direction State}
      ID=PlayerID
      local CurrentX CurrentY in
	 CurrentX=State.currentPosition.x
	 CurrentY=State.currentPosition.y
	 if {List.member pt(x:CurrentX+1 y:CurrentY) PositionsAva}==true && {List.member pt(x:CurrentX+1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX+1 y:CurrentY)
	    Direction='east'
	    {ModifState {List.append State.pastPositions Position|nil} state.charges Position surface(surface:false time:Input.turnSurface)}
	 elseif  {List.member pt(x:CurrentX y:CurrentY+1) PositionsAva}==true && {List.member pt(x:CurrentX y:CurrentY+1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY+1)
	    Direction='north'
	    {ModifState {List.append State.pastPositions Position|nil} state.charges Position surface(surface:false time:Input.turnSurface)}
	 elseif
	    {List.member pt(x:CurrentX-1 y:CurrentY) PositionsAva}==true && {List.member pt(x:CurrentX-1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX-1 y:CurrentY)
	    Direction='west'
	    {ModifState {List.append State.pastPositions Position|nil} state.charges Position surface(surface:false time:Input.turnSurface)}
	 elseif  {List.member pt(x:CurrentX y:CurrentY-1) PositionsAva}==true && {List.member pt(x:CurrentX y:CurrentY-1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY-1)
	    Direction='south'
	    {ModifState {List.append State.pastPositions Position|nil} state.charges Position surface(surface:false time:Input.turnSurface)}
	 else
	    Position=pt(x:CurrentX y:CurrentY)
	    Direction='surface'
	    {ModifState null state.charges Position surface(surface:true time:Input.turnSurface)}
	 end 
      end

   %----------------------------------------------------------------   
   %-------------Autres Fonctions------------------------------------------
   %-----------------------------------------------------------------
      fun{ModifState PastPositions Charges CurrentPosition Surface}
	 state(pastPosition:PastPositions charges:Charges currentPosition:CurrentPosition surface:Surface)
      end


   
   %Returns a list of positions pt(x:X y:Y) where there is no island
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
      
   %prends un element au hasard dans une liste
      fun{PickRandom Liste}
	 local Num Len in
	    Len={List.length Liste}
	    Num=({OS.rand} mod Len)+1
	    {List.nth Liste Num}%Prends le Num element de la liste
	 end      
      end





   end

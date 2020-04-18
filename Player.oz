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
   

   
   % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface)
   proc{TreatStream Stream State} % as as many parameters as you want
      case Stream of initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	 {TreatStream T {InitPosition ID Position}}

	 
	 %----------------Actions---------Work in progress...
      []move(ID Position Direction)|T then
	 {TreatStream T {Move ID Position Direction State}} 
      []dive|T then
	 {TreatStream T {Dive State}}
      []chargeItem(ID KindItem)|T then
	 {TreatStream T {ChargeItem ID KindItem State}}
      []fireItem(ID KindFire)|T then
	 {TreatStream T {FireItem ID KindFire State}}
      []fireMine(ID Mine)|T then
	 skip
      []isDead(Answer)|T then
	 skip
      %--------------Messages--WIP
	 
      []sayMove(ID Direction)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction State}}
	 end
      []saySurface(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SaySurface ID State}}
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayCharge ID KindItem State}}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMinePlaced ID State}}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMissileExplode ID State}}
	 end
      []sayMineExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMineExplode ID Position Message State}}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingDrone Drone ID Answer State}}
	 end
      []sayAnswerDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerDrone Drone ID Answer State}}
	 end
      []sayPassingSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingSonar ID Answer State}}
	 end
      []sayAnswerSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerSonar ID Answer State}}
	 end	 
      []sayDeath(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDeath ID}}
	 end
      []sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDamageTaken ID Damage LifeLeft State}}
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
	 {TreatStream Stream nil}
      end
      Port
   end


   fun{InitPosition ID Position}
      ID=PlayerID
      Position=Spawn
      {ModifState nil items(missile:0 mine:0 sonar:0 drone:0) charges(missile:0 mine:0 sonar:0 drone:0) Position surface(surface:true time:0)}
      %le premier tour on est surface et au tour suivant on peut dive?
   end


   %-------------------------------------------------
   %-------Fonctions pour les messages:--------------
   %-------------------------------------------------
   fun{SayMove ID Direction State}
      ID=PlayerID
      {System.show 'Player of ID:'#ID#'is moving'#Direction#'!'}
      State
   end


   %----------------------------------------------
   %-----Fonctions pour les actions:--------------
   %----------------------------------------------
   %Si on peut aller a droite on y va, sinon on monte, sinon on va a gauche, sinon on descend, sinon on surface.
   %retourne le nouveau state
   fun{Move ID Position Direction State}
      ID=PlayerID
      local CurrentX CurrentY in
	 CurrentX=State.currentPosition.x
	 CurrentY=State.currentPosition.y
	 if {List.member pt(x:CurrentX+1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX+1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX+1 y:CurrentY)
	    Direction='east'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface}
	 elseif  {List.member pt(x:CurrentX y:CurrentY+1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY+1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY+1)
	    Direction='north'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface}
	 elseif
	    {List.member pt(x:CurrentX-1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX-1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX-1 y:CurrentY)
	    Direction='west'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface}
	 elseif  {List.member pt(x:CurrentX y:CurrentY-1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY-1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY-1)
	    Direction='south'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface}
	 else
	    Position=pt(x:CurrentX y:CurrentY)
	    Direction='surface'
	    {ModifState nil State.items State.charges Position surface(surface:true time:Input.turnSurface)}
	 end 
      end
   end

   %Si on peut charger on charge le missile en premier, sinon la mine, sinon le drone, sinon le sonar.
   fun{ChargeItem ID KindItem State}
      ID=PlayerID
      if State.charges.missile+1<Input.missile then
	 KindItem=missile
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile+1 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface}	 
      else
	 KindItem=missile
	 {ModifState State.pastPositions items(missile:State.items.missile+1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) charges(missile:0 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface}	 
      end
      if State.charges.mine+1 < Input.mine then
	 KindItem=mine
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mines+1 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface}	 
      else
	 KindItem=mine
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine+1 sonar:State.items.sonar drone:State.items.drone) charges(missile:State.charges.missile mine:0 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface}	 
      end	 
      if
	 State.charges.drone+1 <Input.drone then
	 KindItem=drone
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone+1) State.currentPosition State.surface}	
      else
	 KindItem=drone
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone+1) charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar drone:0) State.currentPosition State.surface}
      end	    
      if
	 State.charges.sonar+1 < Input.sonar then
	 KindItem=sonar
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar+1 drone:State.charges.drone) State.currentPosition State.surface}	
      else
	 KindItem=sonar
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar+1 drone:State.items.drone) charges(missile:State.charges.missile mine:State.charges.mine sonar:0 drone:State.charges.drone) State.currentPosition State.surface}	 
      end	       	  
   end

   
   fun{FireItem ID KindFire State}
      ID=PlayerID
   end




   
   fun{Dive State}
      {ModifState nil State.items State.charges State.currentPosition surface(surface:false time:0)}
   end


   

   %----------------------------------------------------------------   
   %-------------Autres Fonctions------------------------------------------
   %-----------------------------------------------------------------
   fun{ModifState PastPositions Items Charges CurrentPosition Surface}
      state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface)
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

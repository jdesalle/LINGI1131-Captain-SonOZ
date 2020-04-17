functor
import
   Input
   System
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
in
   proc{TreatStream Stream <p1> <p2> ...} % as as many parameters as you want
        % ...
      case Stream
      of getId(ID)|T then
	 {System.show 'treating GetId'}
	 {TreatStream T {GetId State ID}}
      []initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	% {TreatStream T {InitPosition ....}
	 %-----------------Messages---------Work in progress...
      []sayMove(ID Direction)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []saySurface(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []sayMineExplode(ID Position Message|T) then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction}}
	    endp
	 []sayAnswerDrone(Drone ID Answer)|T then
	    if ID== null then skip
	    else
	       {TreatStream T {SayMove ID Direction}}
	    end
	 []sayPassingSonar(ID Answer)|T then
	    if ID== null then skip
	    else
	       {TreatStream T {SayMove ID Direction}}
	    end
	 []sayAnswerSonar(ID Answer)|T then
	    if ID== null then skip
	    else
	       {TreatStream T {SayMove ID Direction}}
	    end
	 
	 []sayDeath(ID)|T then
	    if ID== null then skip
	    else
	       {TreatStream T {SayMove ID Direction}}
	    end
	 []sayDamageTaken(ID Damage LifeLeft)|T then
	    if ID== null then skip
	    else
	       {TreatStream T {SayMove ID Direction}}
	    end
	 end
      end

   %A FINIR POUR L'INITIALISATION
      fun{StartPlayer Color ID}
	 Stream
	 Port
      in
	 {NewPort Stream Port}
	 thread
	    {TreatStream Stream <p1> <p2> ...}
	 end
	 Port
      end

%-------Fonctions pour les messages
      fun{SayMove ID Direction}
	     {System.show 'Player of ID:'#ID#'is moving'#Direction#'!'}
      end
   end


end

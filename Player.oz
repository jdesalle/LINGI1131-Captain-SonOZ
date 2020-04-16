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
   GetId
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
	 {TreatStream T {InitPosition ....}

%Ici il faut traiter le cas pour chaque message que player doit handle.
      end
   end
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


   %useless for now
   fun {GetId State ID}
      ID=State.id
      {System.show 'executing GetId'}
      State
   end  
end

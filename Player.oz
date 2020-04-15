functor
import
    Input
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
	  {TreatStream T {GetId State ID}}

%Ici il faut traiter le cas pour chaque fonction de player..
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
    
    fun {GetId State ID}
ID=State.id
State
    end  
end

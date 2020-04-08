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
end
